# Using Terragrunt to deploy to Incubator

## Setup Incubator Project Directories

Under `/incubtaor`, select the corresponding environment to deploy to. For example, to deploy a Django application into Hack For LA's AWS account within a `dev` environment, one should create a
`incubator/project-dev/django-application-example` directory for the codebase. 

## Configure `project.hcl`

`project.hcl` helps provide environmental variables and configuration for the incubator deployed application. This file will have aspects such as the host_names, container settings, and health checks url routes. 

There should also be a `terragrunt.hcl` within the directory as well, but it doesn't need to be configured. This file will will copy the Terraform configurations specified by the source parameter, along with any files in the
working directory, into a temporary folder, and execute Terraform commands in that folder.

## Deploy with Terragrunt

```console
terragrunt init
terragrunt plan
terragrunt apply
```

After `apply` one can examine AWS ECS console for activity. 

To remove application from AWS ECS:
```console
terragrunt destroy
```

