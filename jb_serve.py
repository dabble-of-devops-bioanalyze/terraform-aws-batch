import subprocess
from pathlib import Path
from copy import deepcopy
import os
import formic
import re
import glob
import json
import tempfile
import typing
from typing import TypedDict, Any, List
import functools
from functools import cache, lru_cache
import shutil
from pprint import pprint
from cookiecutter import config
from cookiecutter.main import cookiecutter
from cookiecutter.generate import generate_context
from cookiecutter.repository import determine_repo_dir
from cookiecutter.config import get_user_config
import click
from livereload import Server

import configparser
import git
from colorlog import ColoredFormatter
import logging, colorlog

FORMAT = "%(log_color)s[%(levelname)-8s%(filename)s:%(lineno)s - %(funcName)15s() ] %(blue)s%(message)s"
formatter = ColoredFormatter(
    FORMAT,
    datefmt=None,
    reset=True,
    log_colors={
        "DEBUG": "cyan",
        "INFO": "green",
        "WARNING": "yellow",
        "ERROR": "red",
        "CRITICAL": "red,bg_white",
    },
    secondary_log_colors={},
    style="%",
)
handler = logging.StreamHandler()
handler.setFormatter(formatter)
logger = logging.getLogger("jupyterbook")
logger.addHandler(handler)
logger.setLevel("INFO")


# This tool comes from - https://gist.github.com/tnwei/726d377410b9a6285ddc1b18c4e67dc6
# with thanks!

THIS_DIR = os.path.dirname(os.path.abspath(__file__))

TEMPLATES_DIR = os.path.join(THIS_DIR, "_templates")
EXAMPLES_DIR = os.path.join(THIS_DIR, "examples")
DOCS_DIR = THIS_DIR

COOKIECUTTER_TEMPLATE_REPO = (
    "https://github.com/dabble-of-devops-bioanalyze/terraform-example-module"
)
COOKIECUTTER_TEMPLATE_DIR = "_templates/terraform-cookiecutter"

TF_INCLUDE = ["**.tf", "**.tpl", "**.json", "**.md", "**.py"]
TF_EXCLUDE = [
    "**/_html/**",
    "_html",
    ".terraform",
    "backend.tf",
    "**/backend.tf.html",
    "**/backend.tf",
    "**/.terraform",
    "**/.terraform/**",
    "**/.terraform",
    "**/.pytest_cache/**",
    "**/.pytest_cache",
    "tests/__pycache__/**",
    "tests/__pycache__",
    "*.tfvars.json",
    "**/*.tfvars.json",
    "*.tfvars",
    "**/*.tfvars",
]
TF_COOKIECUTTER_INCLUDE = [
    "**.tf",
    "**.tpl",
    "**.json",
    "**.md",
    "**.config",
    "**.py",
    "_html",
    "**/_html",
    "_html/**",
    "**/_html/**",
]
TF_COOKIECUTTER_EXCLUDE = [
    ".terraform",
    "backend.tf",
    "**/backend.tf",
    "**/.terraform",
    "**/.terraform/**",
    "**/.terraform",
    "**/.pytest_cache/**",
    "**/.pytest_cache",
    "tests/__pycache__/**",
    "tests/__pycache__",
    "*.tfvars.json",
    "**/*.tfvars.json",
    "*.tfvars",
    "**/*.tfvars",
]
JB_INCLUDE = ["**.rst", "**.yaml", "**.yml", "**.md", "**/*.ipynb"]
JB_EXCLUDE = [
    "**/_html/**",
    "_html",
    "docs",
    "docs/*",
    "_build",
    "_build/**",
    "tests/__pycache__/**",
    "tests/__pycache__",
    ".github",
    ".github/**",
]

# Copy these dirs/files from source to dest
COPY = [
    "tests",
    "*tf",
    "**/*tf",
    "*md",
    "**/*md",
    "*.rst",
    "**/*rst",
    "_html",
    "**/_html",
    "*json",
    "**/*json",
    "*tpl",
    "**/*tpl",
]
# Clean up these dirs/files
CLEAN = [
    ".pytest_cache",
    "tests/__pycache__",
    ".terraform.lock.hcl",
    ".terraform",
    "terraform.tfstate",
    "terraform.tfstate.backup",
]


class CookiecutterDir(TypedDict):
    # directory containing the original example - usually example/name-of-example
    example_dir: Path
    # temp directory generated
    temp_dir: Path
    # directory to final cookiecutter - _templates/name-of-example/{{cookiecutter.project_name}}
    destination_dir: Path


def get_git_url():
    repo = git.Repo(".", search_parent_directories=True)
    config_file = os.path.join(repo.working_tree_dir, ".git", "config")

    config = configparser.ConfigParser()
    config.read(config_file)
    return config['remote "origin"']["url"]


def bootstrap():
    logger.info("Bootstraping directories")
    os.makedirs(
        os.path.join(THIS_DIR, "_templates", "module"), mode=0o777, exist_ok=True
    )
    os.makedirs(
        os.path.join(THIS_DIR, "_templates", "examples"), mode=0o777, exist_ok=True
    )


def generate_fileset(
    include: List[str], exclude: List[str], directory: Path, return_relative: True
):
    examples_fileset = formic.FileSet(
        include=include, exclude=exclude, directory=directory, symlinks=False,
    )
    files = []
    for file in examples_fileset:
        if return_relative:
            files.append(os.path.relpath(file, directory))
        else:
            files.append(file)
    return files


@click.command()
@click.argument("pathsource", default=".", type=Path)
@click.option("-o", "--outputdir", default="docs", type=Path, show_default=True)
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
    outputdir: Directory where HTML output is generated. `jb` defaults to `docs` for deployment with GH pages.
    examplesdir: Directory where terraform examples are located. defaults to `examples`.
    port: Port to host the webserver. Default is 8002

    \b
    Refs
    ----
    + https://github.com/executablebooks/sphinx-autobuild/issues/99#issuecomment-722319104
    + mkdocs docs on github
    """
    git_url = get_git_url()
    bootstrap()

    def cleanup_cookiecutter(example: CookiecutterDir):
        """We end up with a few directories we don't want, mainly, __pycache__ and .pytest_cache"""
        # need to copy with keeping the directories in sync
        # shutil.copytree(example["example_dir"], example["destination_dir"])
        logger.debug(f'Post processing: {os.path.relpath(example["destination_dir"])}')
        copy_fileset = generate_fileset(
            include=TF_COOKIECUTTER_INCLUDE,
            exclude=TF_COOKIECUTTER_EXCLUDE,
            directory=example["example_dir"],
            return_relative=True,
        )
        includes_tmp = tempfile.NamedTemporaryFile(delete=False)
        with open(includes_tmp.name, 'w') as fh:
            fh.write("\n".join(copy_fileset))

        # TODO Change all hacky references to cwd to a root dir
        rsync_command = f"""rsync -avz  -m \
    --include="*/"  \
    --include-from={includes_tmp.name} \
    --exclude="*" \
     {os.path.relpath(example["example_dir"], os.getcwd())}/* \
     {os.path.relpath(example["destination_dir"], os.getcwd())}/
        """
        logger.info('Rsyncing: ')
        logger.info(rsync_command)
        subprocess.run(
            [
                "bash",
                "-c",
                rsync_command,
            ]
        )

        # This shouldn't really be necessary
        # But I'm paranoid so here we are
        for clean in CLEAN:
            logger.debug(f'Removing {example["destination_dir"]}/{clean}')
            clean_this = os.path.join(example["destination_dir"], clean)
            if os.path.exists(clean_this):
                subprocess.run(
                    ["bash", "-c", f'rm -rf {clean_this}',]
                )

    def gencookiecutter_dirs() -> List[CookiecutterDir]:
        """
        First time around we write out the cookiecutter template to a temporary directory
        Then copy it over
        """
        examples = glob.glob(os.path.join(THIS_DIR, "examples", "*"), recursive=False)
        example_dirs: List[CookiecutterDir] = []
        seen = {}
        for example in examples:
            if (
                os.path.isdir(example)
                and example not in seen
                and "_html" not in example
            ):
                temp_dir = tempfile.TemporaryDirectory()
                seen[example] = 1
                example_dirs.append(
                    {
                        "example_dir": example,
                        "destination_dir": os.path.join(
                            TEMPLATES_DIR,
                            "examples",
                            os.path.basename(example),
                            "{{cookiecutter.project_name}}",
                        ),
                        "temp_dir": temp_dir.name,
                    }
                )

        return example_dirs

    def gen_terraform_json_variables(example):
        example_dir = os.path.join(examplesdir, os.path.basename(example))
        # get the json tfvars
        tfvars_json = tempfile.NamedTemporaryFile(suffix=".json", delete=False)
        command = f" terraform-docs tfvars json {example_dir} > {tfvars_json.name}"
        subprocess.run(["bash", "-c", command])
        f = open(tfvars_json.name)
        data = json.load(f)
        if "context" in data:
            del data["context"]
        os.remove(tfvars_json.name)

        tfvars_hcl = tempfile.NamedTemporaryFile(suffix=".hcl", delete=False)
        # TODO Need to remove the context from the TFVARs
        command = f" terraform-docs tfvars hcl {example_dir} > {tfvars_hcl.name}"
        subprocess.run(["bash", "-c", command])
        f = open(tfvars_hcl.name)
        hcl = f.read()
        os.remove(tfvars_hcl.name)

        # Generate the terraform markdown docs
        command = f" terraform-docs markdown {example_dir} > {example_dir}/terraform-requirements.md"
        subprocess.run(["bash", "-c", command])

        # Return the variables in JSON and HCL format
        return data, hcl

    def gencookiecutter_context(example: CookiecutterDir, extra_context):

        config_dict = get_user_config(config_file=None, default_config=False,)
        repo_dir, cleanup = determine_repo_dir(
            template=COOKIECUTTER_TEMPLATE_REPO,
            abbreviations=config_dict["abbreviations"],
            clone_to_dir=config_dict["cookiecutters_dir"],
            checkout=None,
            no_input=True,
            password=None,
            directory=COOKIECUTTER_TEMPLATE_DIR,
        )
        context_file = os.path.join(repo_dir, "cookiecutter.json")
        cookiecutter_context = generate_context(
            context_file=context_file,
            default_context=config_dict["default_context"],
            extra_context=extra_context,
        )
        cookiecutter_file = str(Path(example["destination_dir"]).parents[0])
        cookiecutter_file = os.path.join(cookiecutter_file, "cookiecutter.json")
        logger.debug(cookiecutter_context)
        logger.info(f"Writing cookiecutter context to: {cookiecutter_file}")

        with open(cookiecutter_file, "w") as f:
            json.dump(cookiecutter_context["cookiecutter"], f, indent=4)

    def gencookiecutters():
        """
        cookiecutter https://github.com/user/repo-name.git --directory="directory1-name"
        """
        cookiecutter_dirs = gencookiecutter_dirs()
        for example in cookiecutter_dirs:

            terraform_json, terraform_hcl = gen_terraform_json_variables(
                example["example_dir"]
            )

            title = os.path.basename(example["example_dir"])
            title = title.title()
            extra_context = {
                "terraform_variables": terraform_json,
                "terraform_hcl": terraform_hcl,
                "docs_data": {
                    "title": f"AWS Batch - {title}",
                    "github_repo": git_url,
                    "directory": os.path.join(
                        "_templates", os.path.relpath(example["example_dir"])
                    ),
                },
            }

            cookiecutter(
                COOKIECUTTER_TEMPLATE_REPO,
                directory=COOKIECUTTER_TEMPLATE_DIR,
                overwrite_if_exists=True,
                extra_context=extra_context,
                output_dir=example["temp_dir"],
                no_input=True,
            )

            if os.path.exists(example["destination_dir"]):
                shutil.rmtree(example["destination_dir"])
            logger.info(
                f'Copying from: {example["temp_dir"]} to {example["destination_dir"]} '
            )
            shutil.move(example["temp_dir"], example["destination_dir"])
            gencookiecutter_context(example, extra_context)
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
    logger.info("Generating files to watch in terraform examples dirs")
    examples_fileset = generate_fileset(
        include=TF_INCLUDE,
        exclude=TF_EXCLUDE,
        directory=examplesdir,
        return_relative=False,
    )
    for file in examples_fileset:
        logger.debug(f"terraform examples: {file}")
        server.watch(file, pygmentize, delay=DELAY)

    # Globbing for all supported file types under jupyter-book
    # Ignore unrelated files
    logger.info("Generating files to watch in jupyterbook dirs")
    jupyterbook_fileset = generate_fileset(
        include=JB_INCLUDE,
        exclude=JB_EXCLUDE,
        directory=pathsource,
        return_relative=False,
    )
    for file in jupyterbook_fileset:
        logger.debug(f"jupyter-book build: {file}")
        server.watch(file, build, delay=DELAY)

    server.serve(root=outputdir, port=port, host="0.0.0.0")


if __name__ == "__main__":
    main()
