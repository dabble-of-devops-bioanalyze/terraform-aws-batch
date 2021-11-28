.. _howto/connection:gcp:

Google Cloud Connection
================================

The Google Cloud connection type enables the Google Cloud Integrations.

Literal Include
------------------------------

There are two ways to connect to Google Cloud using Airflow.

.. raw:: html
   :file: ./main.tf.html

Code Block
------------------------------

For example, with the following ``terraform`` setup...

.. code-block:: terraform

    #
    # ONLY EDIT THIS FILE IN github.com/cloudposse/terraform-null-label
    # All other instances of this file should be a copy of that one
    #
    #
    # Copy this file from https://github.com/cloudposse/terraform-null-label/blob/master/exports/context.tf
    # and then place it in your Terraform module to automatically get
    # Cloud Posse's standard configuration inputs suitable for passing
    # to Cloud Posse modules.
    #
    # Modules should access the whole context as `module.this.context`
    # to get the input variables with nulls for defaults,
    # for example `context = module.this.context`,
    # and access individual variables as `module.this.<var>`,
    # with final values filled in.
    #
    # For example, when using defaults, `module.this.context.delimiter`
    # will be null, and `module.this.delimiter` will be `-` (hyphen).
    #

    module "this" {
      source  = "cloudposse/label/null"
      version = "0.24.1" # requires Terraform >= 0.13.0

      enabled             = var.enabled
      namespace           = var.namespace
      environment         = var.environment
      stage               = var.stage
      name                = var.name
      delimiter           = var.delimiter
      attributes          = var.attributes
      tags                = var.tags
      additional_tag_map  = var.additional_tag_map
      label_order         = var.label_order
      regex_replace_chars = var.regex_replace_chars
      id_length_limit     = var.id_length_limit
      label_key_case      = var.label_key_case
      label_value_case    = var.label_value_case

      context = var.context
    }


    resource "google_service_account_iam_member" "sa_2_member" {
      service_account_id = "${google_service_account.sa_2.name}"
      role               = "roles/iam.serviceAccountTokenCreator"
      member             = "serviceAccount:${google_service_account.sa_1.email}"
    }

...we should configure Airflow Connection to use ``impersonation-chain-1`` account's key and provide
following value for ``impersonation_chain`` argument...

.. code-block:: python

        PROJECT_ID = os.environ.get("TF_VAR_project_id", "your_project_id")
        IMPERSONATION_CHAIN = [
            f"impersonation-chain-2@{PROJECT_ID}.iam.gserviceaccount.com",
            f"impersonation-chain-3@{PROJECT_ID}.iam.gserviceaccount.com",
            f"impersonation-chain-4@{PROJECT_ID}.iam.gserviceaccount.com",
        ]

...then requests will be executed using ``impersonation-chain-4`` account's privileges.
