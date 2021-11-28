import subprocess
from pathlib import Path
import os
import glob
import json
import tempfile

from pprint import pprint
from cookiecutter import config
from cookiecutter.main import cookiecutter
import click
from livereload import Server

import configparser
import git

# This tool comes from - https://gist.github.com/tnwei/726d377410b9a6285ddc1b18c4e67dc6
# with thanks!

def get_git_url():
    repo = git.Repo('.', search_parent_directories=True)
    config_file = os.path.join(repo.working_tree_dir, '.git', 'config')

    config = configparser.ConfigParser()
    config.read(config_file)
    sections = config.sections()
    return config['remote "origin"']['url']


@click.command()
@click.argument("pathsource", default=".", type=Path)
@click.option("-o", "--outputdir", default="_build/html", type=Path, show_default=True)
@click.option("-e", "--examplesdir", default="examples", type=Path, show_default=True)
@click.option("-p", "--port", default=8002, type=click.INT, show_default=True)
def main(pathsource: Path, examplesdir: Path, outputdir: Path, port: int):
    """
    Script to serve a jupyter-book site, which rebuilds when files have
    changed and live-reloads the site. Basically `mkdocs serve`
    but for jupyter-book. Use by calling `python jb-serve.py [OPTIONS] [PATH_SOURCE]`.

    \b
    Args
    ----
    PATHSOURCE: Directory in `jb build <dir>`
    outputdir: Directory where HTML output is generated. `jb` defaults to `_build/html`
    examplesdir: Directory where terraform examples are located. defaults to `examples`.
    port: Port to host the webserver. Default is 8002

    \b
    Refs
    ----
    + https://github.com/executablebooks/sphinx-autobuild/issues/99#issuecomment-722319104
    + mkdocs docs on github
    """
    git_url = get_git_url()

    def cleanup_cookiecutter(example):
        """We end up with a few directories we don't want, mainly, __pycache__ and .pytest_cache"""
        dirs = glob.glob(os.path.join(example, "**", ".pytest_cache"), recursive=True)
        for dir in dirs:
            subprocess.run(["bash", "-c", f"rm -rf {dir}"])
        dirs = glob.glob(os.path.join(example, "**", "__pycache__"), recursive=True)

        subprocess.run(["bash", "-c", f"rm -rf {example}/.terraform"])
        subprocess.run(["bash", "-c", f"rm -rf {example}/terraform.tfstate"])
        subprocess.run(["bash", "-c", f"rm -rf {example}/terraform.tfstate.backup"])

        for dir in dirs:
            subprocess.run(["bash", "-c", f"rm -rf {dir}"])

    def gencookiecutter_dirs():
        os.makedirs("_templates/module", mode=0o777, exist_ok=True)
        os.makedirs("_templates/examples", mode=0o777, exist_ok=True)
        examples = glob.glob("examples/*")
        example_dirs = []
        for example in examples:
            if (
                os.path.isdir(example)
                and example not in example_dirs
                and "_html" not in example
            ):
                example_dirs.append(os.path.join("_templates", example))

        return example_dirs

    def gen_terraform_json_variables(example):
        example_dir = os.path.join(examplesdir, os.path.basename(example))
        tf = tempfile.NamedTemporaryFile(suffix=".json", delete=False)
        command = f" terraform-docs tfvars json {example_dir} > {tf.name}"
        subprocess.run(["bash", "-c", command])
        f = open(tf.name)
        data = json.load(f)
        del data["context"]
        return data

    def gencookiecutters():
        """
        cookiecutter https://github.com/user/repo-name.git --directory="directory1-name"
        """
        cookiecutter_dirs = gencookiecutter_dirs()
        cookiecutter_template_dir = (
            "https://github.com/dabble-of-devops-bioanalyze/terraform-example-module"
        )
        for example in cookiecutter_dirs:
            subprocess.run(["bash", "-c", f"rm -rf {example}"])
            subprocess.run(["bash", "-c", f"mkdir -p {example}"])
            terraform_variables = gen_terraform_json_variables(example)
            title = os.path.basename(example)
            title = title.title()
            cookiecutter(
                cookiecutter_template_dir,
                directory="_templates/terraform-cookiecutter",
                overwrite_if_exists=True,
                extra_context={
                    "terraform_variables": terraform_variables,
                    "docs_data": {
                        "title": f"AWS Batch - {title}",
                        "github_repo": git_url,
                        "directory": example,
                    },
                },
                output_dir=example,
                no_input=True,
            )
            example_dir = os.path.join(examplesdir, os.path.basename(example))
            subprocess.run(["bash", "-c", f"cp -rf {example_dir}/main.tf {example}/"])
            subprocess.run(
                ["bash", "-c", f"cp -rf {example_dir}/context.tf {example}/"]
            )
            subprocess.run(
                ["bash", "-c", f"cp -rf {example_dir}/variables.tf {example}/"]
            )
            cleanup_cookiecutter(example)

    def pygmentize():
        terraform_files = glob.glob(f"{examplesdir}/**/**.tf", recursive=True)
        for terraform_file in terraform_files:
            dirname = os.path.dirname(terraform_file)
            tf_html_dir = os.path.join(dirname, "_html")
            basename = os.path.basename(terraform_file)
            tf_html_file = os.path.join(tf_html_dir, f"{basename}.html")
            if not os.path.exists(tf_html_dir):
                subprocess.run(["mkdir", "-p", tf_html_dir])
            subprocess.run(
                [
                    "bash",
                    "-c",
                    f"pygmentize -l terraform -f html {terraform_file} > {tf_html_file}",
                ]
            )

        gencookiecutters()

    def build():
        subprocess.run(["jb", "clean", pathsource])
        subprocess.run(["jb", "build", pathsource])

    # Build if not exists upon startup
    if not os.path.exists(outputdir):
        build()

    gencookiecutters()
    server = Server()

    DELAY = 10
    # Globbing for all supported file types under examplesdir
    server.watch(os.path.join(examplesdir, "**/**.tf"), pygmentize, delay=DELAY)
    server.watch(os.path.join(examplesdir, "**/**.tfvars"), pygmentize, delay=DELAY)
    server.watch(os.path.join(examplesdir, "**/*.tf"), pygmentize, delay=DELAY)
    server.watch(os.path.join(pathsource, "**/*.tf"), pygmentize, delay=DELAY)
    server.watch(os.path.join(pathsource, "*.tf"), pygmentize, delay=DELAY)

    # Globbing for all supported file types under jupyter-book
    # Ignore unrelated files
    server.watch(os.path.join(examplesdir, "**/*.md"), build)
    server.watch(os.path.join(pathsource, "**/*.md"), build)
    server.watch(os.path.join(pathsource, "**/*.ipynb"), build)
    server.watch(os.path.join(pathsource, "**/**.rst"), build)
    server.watch(pathsource / "_config.yml", build)
    server.watch(pathsource / "_toc.yml", build)

    server.serve(root=outputdir, port=port, host="0.0.0.0")


if __name__ == "__main__":
    main()
