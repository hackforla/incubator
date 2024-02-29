# Migrating a Project from Terragrunt to Terraform

### TL;DR

First, please do read this guide,
as it (hopefully) explains how to construct a Terraform module
based on the Terragrunt configurations that already exist.

That said, all the existing Terragrunt looks very similar,
so it should be possible to crib from the `people-depot` module
and its `dev` environment.
In essence, you should be able to
copy `terraform-modules/people-depot`
to an appropriate directory for your project,
and then update the
`terraform-modules/<project>/project/main.tf`
file to reflect values you find in `incubator/`.

We're all here to learn things though,
and reading through this guide should help explain
the process and goals of the migration.
It'll also help figure out how to fix issues along the way.

## Purpose

Ops intends to move everything from Terragrunt to Terraform.
This guide describes the process of migrating a single project
to Terraform.
It may also be useful in terms of understanding how to set up
a new project in the Incubator Terraform.

## Starting Point

### From Terragrunt...

We'll be using
`incubator/projects-dev/people-depot-backend/`
as our example here.

Let's look at the old Terragrunt directory structure:
```
incubator
├── account.hcl
├── env.hcl
├── projects-dev
│  ├── ballotnav-api
│  │  └── terragrunt.hcl
│  ├── people-depot-backend // <- THIS project
│  │  ├── project.hcl
│  │  └── terragrunt.hcl
│  ├── terragrunt.hcl
│  ├── vrms-backend
│  │  └── terragrunt.hcl
│  └── vrms-client
│     └── terragrunt.hcl
├── projects-prod
    ....
├── projects-stage
│  ├── civictechindex-api
│  │  └── terragrunt.hcl
│  └── terragrunt.hcl
└── shared-resources
   ├── acm
   │  └── terragrunt.hcl
   ├── alb
   │  └── terragrunt.hcl
   ├── backend.tf
   ├── bastion
   │  └── terragrunt.hcl
   ├── cicd
   │  └── terragrunt.hcl
   ├── ecs
   │  └── terragrunt.hcl
   ├── multi-db-lambda
   │  └── terragrunt.hcl
   ├── network
   │  └── terragrunt.hcl
   ├── provider.tf
   ├── rds
   │  └── terragrunt.hcl
   └── terragrunt.hcl
```

This is the listing from a workstation set up to deploy `people-depot-backend`
with Terragrunt,
which is why we see a `project.hcl` here.
To start this process, you'll need the `project.hcl` for the project you're trying to migrate. 

DISCLAIMER: For some projects that file is hard (impossible?) to locate. You can actually still do the migration without it by reading the Terraform state directly which we'll show later in the documentation but it's **much** easier to do with the `project.hcl` file so reach out to the relevant slack channels to find it.

Inside that file
(`incubator/projects-dev/people-depot-backend/project.hcl`)
we see:
```hcl
locals {
  // General Variables
  project_name = "people-depot"
  environment  = "dev"

  // ALB
  aws_managed_dns = false
  host_names      = ["people-depot-backend.com"]
  path_patterns   = ["/*"]

  // ECS
  application_type = "backend"
  launch_type      = "FARGATE"

  // RDS (Database)
  postgres_database = {
  }

  container_image   = "035866691871.dkr.ecr.us-west-2.amazonaws.com/people-depot-backend-dev:latest"
  desired_count     = 1
  container_port    = 8000
  container_memory  = 512
  container_cpu     = 256
  health_check_path = "/"

  // Container variables
  container_env_vars = {
    SECRET_KEY="foo"
    DJANGO_ALLOWED_HOSTS="localhost 127.0.0.1 [::1]"
    SQL_ENGINE="django.db.backends.postgresql"
    SQL_DATABASE="people_depot_dev"
    SQL_USER="people_depot"
    SQL_PASSWORD="[XXX REDACTED XXX]"
    SQL_HOST="incubator-prod-database.cewewwrvdqjn.us-west-2.rds.amazonaws.com"
    SQL_PORT=5432
    DATABASE="postgres"

    COGNITO_AWS_REGION="us-west-2"
    COGNITO_USER_POOL="us-west-2_Fn4rkZpuB"
  }
}
```

There's a lot of details there,
and while most of them are important,
we don't have to care too much about them
for this.

### ...to Terraform

Let's look now at the `terraform-incubator` directory:
```
terraform-incubator
├── people-depot
│  ├── dev
│  │  ├── main.tf <-- LOOK HERE
│  │  └── secrets.auto.tfvars
│  ├── prod
│  ├── project # <-- AND HERE
│  │  └── main.tf
│  └── stage
└── shared_resources
   ├── alb
   ├── all
   │  └── main.tf
   ├── ecs
   ├── multi-db-lambda
   ├── network
   │  ├── main.tf
   │  └── moves.tf
   └── rds
```

It's a little bit simpler,
but that's mostly because
we're in early days of the migration.
We're going to take stuff from that `project.hcl` file,
and some other files in the Terragrunt `incubator.hcl`
and copy and paste them into
(in this example)
`terraform-incubator/people_depot/project/main.tf`
and
`terraform-incubator/people_depot/dev/main.tf`.
You'll replace `people-depot`
with the name of your project.

We put data in one file or the other,
to support the DevOps idea of lifecycles.
Ideally, each project should
at least
have a "staging" and "production" environment,
so that it can be deployed first to staging to validate than the new version isn't broken,
and then "promoted" to production.
It's not uncommon to also have a "development" deployment target,
so that during active work on the project,
engineers can push new versions and try them out,
without worrying about disrupting Staging.

The three environments should be very similar -
there's varying levels of dogma about how similar Staging and Production should be
(the right answer is "exactly the same, always" ;) -JDL).
Therefore, we have a central "project" module where we'll collect the common configuration,
which should be most of it,
and then let the root modules for each environment
tweak that with things like a different URL and database name.

## Getting To Work

First,
we'll start a new branch for the migration in our fork of Incubator

Next,
make sure the top level directory (e.g. `people-depot`) is created,
and subdirectories for the `project/` hub, and whatever environments
we want to support.
We can add more later if we need,
so starting with `staging` or `dev` is reasonable.

There'll be several places in `incubator/` we'll be looking for configuration values for `project/main.tf`:
1. `incubator/projects-{dev,staging,prod}/$project/project.hcl`
2. `incubator/projects-{dev,staging,prod}/$project/terragrunt.hcl`
3. `incubator/env.hcl`
4. `incubator/account.hcl`
5. `rds.hcl`

Let's look at our example target `project/main.tf`
and see where each line came from.
We'll talk about each part in comments:
```terraform
# We're going to need some values from the shared resources deployment.
# That part is out of scope for this guide,
# but for now just put this whole data block in the project/main.tf
data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/./terraform.tfstate"
    region         = "us-west-2"
  }
}

# As part of transitioning for Terraform,
# we're going to create this module - use the name of your project
module "people_depot" {
  # In general, we'll use this source -
  # it comes from #1: terragrunt.hcl
  source = "../../../terraform-modules/service"

  # Most of these entries are the combination of
  # the inputs and locals blocks of #1, and
  # specific values from one of the other files
  container_cpu   = 256
```

### Wait up - how did you get there?

It probably is worth discussing how we tracked down,
for instance,
the value `256` here.
First of all, to even know that we need this value,
we need to look at the source module,
in `terrafrom-modules/service/`,
specifically `terrafrom-modules/service/variables.tf`:
where around line 113, we find:
```terraform
variable "container_cpu" {
  type    = number
  default = 0
}
```

Our `terragrunt.hcl` file has this object:
```hcl
inputs = {
  # ...
  container_cpu      = local.container_cpu
  # ...
}
```

So we have to look for locals - that's higher up in the same file:
```hcl
locals {
  project_vars     = read_terragrunt_config("./project.hcl")
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  rds_vars         = read_terragrunt_config(find_in_parent_folders("rds.hcl"))
  # ...
  container_cpu      = local.project_vars.locals.container_cpu
  # ...
}
```

There's those 4 lines right at the beginning that don't seem relevant
until we get to the `container_cpu` line.
Then we see that it's looking at something in `project_vars`,
and we need to see that that comes from the `project.hcl` file.
In there we find this line:
```hcl
  container_cpu     = 256
```

And that's how we found that value!
Only 40-something to go!

To be fair, once you've figured out one,
there's generally a clump
of values that all from from the same file,
so you can cut and paste big swathes.

_But,_
there's the point to be made that if you did want to know
what value was assigned for a particular module,
that's the process to the hunt it down in Terragrunt.
This is one of the reasons we're moving away from it.

If your project does not have a `project.hcl` file or you haven't been able to locate it, you can still get these values by looking at the Terraform state for those resources and pulling them directly.
Run `terraform show > state.txt` from the directory that you've created for the project and environment within terraform-incubator (i.e. terraform-incubator/people-depot/dev). In order for that command to actually pull the state down, you will need to have configured the provider and backend blocks within the `main.tf` file as described [here](#per-environment-configs):
```terraform
terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/projects-{ENV}/{PROJECT}/terraform.tfstate"
    region         = "us-west-2"
  }
}
provider "aws" {
  region = "us-west-2"
}
```
You will need to locate the state file and fill in the correct `key`. Usually it's straightforward and you can just fill in the `ENV` and `PROJECT` but you can also check the location in S3 yourself in this bucket - s3://hlfa-incubator-terragrunt/terragrunt-states/incubator/. Once you get this confiugred properly and pointing at the right state, run `terraform init` and then `terraform show > state.txt` which should populate the text file with the resources that are currently stored in that state. From there, you can back into the values you need from the `project.hcl` by looking at the resource configuration in the state.

getting back to our `project/main.tf` -
we'll skip a bunch of values we can collect this way,
and now we get to ones that aren't as straightforward:
```terraform
  alb_external_dns        = data.terraform_remote_state.shared.outputs.alb_external_dns
  cluster_id              = data.terraform_remote_state.shared.outputs.cluster_id
  task_execution_role_arn = data.terraform_remote_state.shared.outputs.task_execution_role_arn
  alb_security_group_id   = data.terraform_remote_state.shared.outputs.alb_security_group_id
  alb_https_listener_arn  = data.terraform_remote_state.shared.outputs.alb_https_listener_arn
  db_instance_endpoint    = data.terraform_remote_state.shared.outputs.db_instance_endpoint
  vpc_id                  = data.terraform_remote_state.shared.outputs.vpc_id
  public_subnet_ids       = data.terraform_remote_state.shared.outputs.public_subnet_ids
```

What's that all about,
and how did we figure it out?

Those fields are, also,
`variable`s declared in the the `service` module.
In `terragrunt.hcl` they're provided like this:
```hcl
  vpc_id                  = dependency.network.outputs.vpc_id
  vpc_cidr                = dependency.network.outputs.vpc_cidr
  public_subnet_ids       = dependency.network.outputs.public_subnet_ids
  db_instance_endpoint    = dependency.rds.outputs.db_instance_endpoint
  lambda_function         = dependency.multi-db.outputs.lambda_function
  alb_https_listener_arn  = dependency.alb.outputs.alb_https_listener_arn
  alb_security_group_id   = dependency.alb.outputs.security_group_id
  alb_external_dns        = dependency.alb.outputs.lb_dns_name
  cluster_name            = dependency.ecs.outputs.cluster_name
  cluster_id              = dependency.ecs.outputs.cluster_id
  task_execution_role_arn = dependency.ecs.outputs.task_execution_role_arn
```

and a little higher up, we've got the corresponding blocks:
```hcl
dependencies {
  paths = ["../../shared-resources/network", "../../shared-resources/alb", "../../shared-resources/ecs", "../../shared-resources/rds", "../../shared-resources/multi-db-lambda"]
}
dependency "network" {
  config_path = "../../shared-resources/network"
  // skip_outputs = true
  mock_outputs = {
    vpc_id            = "",
    vpc_cidr          = "10.0.0.0/16",
    public_subnet_ids = [""],
  }
}
#...
```

In Terraform,
we've set up a corresponding `shared-resources` module,
which collects the data from each of those smaller modules
e.g. `shared-resources/network`
and re-outputs them.
That's what that `data` block is about at the top of our `main.tf`
and this is where we consume them.
The lines are in a different order,
but they correspond if you match them up.

One last value, and a little extra configuration:
```terraform
  root_db_password = var.root_db_password
}

variable "root_db_password" {
  type        = string
  description = "root database password"
}

variable "app_db_password" {
  type = string
}

variable "container_image" {
  type = string
}
```

What this is about is that we have some values
that we want the `project/main.tf` to treat as variables.
There's two reasons for this:
first, `root_db_password` needs to be kept secret,
so we don't want to commit it to the database.
We'll figure out providing that value from outside so we don't have to publish it later.
The other is the `container_image` -
that's going to vary between environments, so we want to let
e.g. `dev/main.tf` or `prod/main.tf` control that.

## Per Environment Configs

Let's work through that part.
We'll want to create something like
`dev/main.tf` as the _root_ for our configuration.
It'll reference our more complex `project/main.tf`
and fill in the details until it's complete.
Then we can use `dev/main.tf` to do deployments.

Let's take a look at what this root module is going to look like.
We'll talk about each part as we go:

```terraform
terraform {
  backend "s3" {
    bucket         = "hlfa-incubator-terragrunt"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "terragrunt-states/incubator/projects-dev/people-depot-backend/terraform.tfstate"
    region         = "us-west-2"
  }
}
provider "aws" {
  region = "us-west-2"
}

```
This describes the backend storage for the module.
This is where Terraform will store its state data
so that multple operators can safely work together
deploying in our environment.

The "aws" `provider` block sets some defaults
for AWS.

```terraform
variable "root_db_password" {
  type        = string
  description = "root database password"
}

variable "app_db_password" {
  type = string
}
```
We need to fill in the password variables
from the project -
but we still don't want to reveal them
by adding them to the Git repository.
So we add a variable here - we'll get to how we
_fill in_ that variable safely in a second.

```terraform
module "dev" {
  source = "../project"

  root_db_password = var.root_db_password
  app_db_password  = var.app_db_password
  container_image  = "035866691871.dkr.ecr.us-west-2.amazonaws.com/people-depot-backend-dev:latest"
}
```
This is where the important stuff happens.
We reference the `project` module,
and feed it the variables it needs,
including the `container_image` for our developement environment.
If we need to vary more values by lifecycle stage,
we could create variables in the `project` module and fille them in here.

```terraform
moved {
  from = module.ecr.aws_ecr_repository.this
  to   = module.dev.module.people_depot.module.ecr.aws_ecr_repository.this
}
```
This section is a little tricky.
Because we have existing configuration in place,
we want to tell Terraform that certain AWS resources are still the same.
Because Terraform matches its resource names
(based on their full dotted path names)
with AWS resources
(based on their AWS IDs)
we need some way to say
"this thing in Terragrunt is now this thing"
and let Terraform continue to track the state.
This `moved` block is how we say that.

## Providing Secrets

Finally, we'll provide just the secret parts of our configuration
in a way we can distribute safely.

In the `dev/` directory, create `secrets.auto.tfvars`,
with content like:
```
root_db_password = NOPE
app_db_password  = not-in-github
```

Needless to say, the particular values need to be distributed out of band.
_They should not be checked into github._
There's already a .gitignore entry for that file name, though,
so you should be able to create it as needed.
Since the contents are just as above
(one line per variable we need to set a value for)
it could be added to a 1Password vault.

There's already a plan to put them into Github Secrets
and let Github Actions manage the deployments,
which would obviate the need
for anyone (human) to manage the toxic waste that is server credentials.

In the meantime, please add a SECRETS.md
with a note about how to get the necessary data for the `secrets.auto.tfvars`

## Testing The Result

From the `dev/` directory,
try running
```
> terraform init # this, just once
> terraform plan
```
There should be minimal output,
because the configuration you've produced should
closely match the Terragrunt configurations.

If Terraform wants to make a lot of changes,
try running `terragrunt plan` in the equivalent directory under `incubator`.
It's possible that the running resources are out of date -
the Terragrunt output should look a lot like the Terraform version.

Depending on operational concerns,
it may make sense to do a `terragrunt apply`
to stand up a reference deployment,
and then use `terraform plan` to check that your configuration is good.
Keep in mind that running infrastructure costs Hack for LA money,
so prefer this route only if there's an existing need to bring servers up.
