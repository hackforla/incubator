# Legacy Terraform modules

**These modules are kept for historical reference only. Nothing sources them, and they must not be used for new work.**

They are the pre-rewrite module set from the Terragrunt-based platform, superseded by the modules in `terraform/modules/` during the Terragrunt-to-Terraform migration ([hackforla/devops#81](https://github.com/hackforla/devops/issues/81)). That rewrite renamed resources from squashed legacy names to the `project-apptype-env` scheme the live infrastructure uses today.

Deleting this directory was proposed in [hackforla/incubator#164](https://github.com/hackforla/incubator/issues/164) and deliberately declined — it is the best surviving record of how the earlier platform was assembled. The abandoned Terragrunt state files it pairs with, under `s3://hlfa-incubator-terragrunt/terragrunt-states/incubator/projects-*/`, are stale enough that this code is often the clearer account of intent.

## Before you read anything here

- **Nothing references these modules.** Verified 2026-08-29: `grep -rn "modules/legacy" --include=*.tf` returns no hits anywhere in the repository, and no `source =` in any non-legacy `.tf` resolves into this directory. All 15 modules are unreachable from the root configuration.
- **They are not guaranteed to be usable.** At least one is broken as written: `service/ecr.tf` sources `../ecr`, which resolves to `terraform/modules/legacy/ecr` — a path that does not exist. Do not assume anything here still initializes or plans cleanly.
- **They do not describe live infrastructure.** The resources these modules once created have either been replaced by the V2 modules or deleted outright. Read them as history, not as a description of the current account.

If you are trying to understand a live resource, start from `terraform/projects/` and the modules in `terraform/modules/`, not from this directory.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->