# Terraform

_Note:_
Hack for LA is migrating the Incubator
to Terraform from Terragrunt.
Recent releases of Terraform mean that Terragrunt doesn't pull its weight,
and imposes an additional hurdle for learning
Infrastructure as Code (IaC) and HfLA Operations practices.
Be aware that the current status of Terraform
bears marks of the history with Terragrunt.

## Terraform Migration

The first consequence of Terragrunt is
that individual projects that were configured with Terragrunt
will need Terraform configuration created.

Review the guide
[here](./terraform-migrate-project.md)
for details.

## Note: Intermedia Shared Resources

To support the transition to Terraform,
we've created a module to manage
the resources that are shared in our infrastructure.
Because of how _Terragrunt_ handles modules,
we have about a half dozen modules to manage.
This requires special handling,
and will eventually need to be handled properly.

A guide about this process is
[here.](./terraform-shared-resources.md)
