## Overview
This repository contains all the necessary modules needed to create AWS resources used by Hack for LA's projects.

Learn more at the [incubator wiki](https://github.com/hackforla/incubator/wiki)

## Running `terraform plan` locally

A plan has to connect to the shared database, so it needs a database login as well as AWS access. Contributors use `terraform_plan`, a login that can read everything a plan needs and change nothing.

**This login is for `terraform plan` only.** `terraform apply` is not available to contributors. Changes are applied by CI when a pull request merges.

1. Get AWS access to the incubator account (`035866691871`) through your IAM user. This README does not cover it.
2. Install Terraform 1.16.x. `terraform/backend.tf` pins `~> 1.16.0`, and other versions won't initialise against the state.
3. Download `terraform.tfvars` from the DevOps 1Password vault and save it in the `terraform/` directory. Terraform loads that file automatically, so there is no flag to pass and nothing to export. It is gitignored. [`terraform/terraform.tfvars.example`](terraform/terraform.tfvars.example) shows what it contains.
4. From `terraform/`, run:

   ```bash
   terraform init -backend-config=prod.backend.tfvars
   terraform plan
   ```

On `main`, the plan should report no changes.

> **If you also have the master password:** values in `terraform.tfvars` override `TF_VAR_*` environment variables. With that file in `terraform/`, Terraform connects as `terraform_plan` even if you have exported `TF_VAR_pgpassword`. Move the file aside when you need the master login.
