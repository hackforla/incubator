# Under construction - github.com/darpham
## Overview
This repository contains all the necessary modules needed to create the following resources in AWS.

1. VPC (Virtual Private Cloud), including subnets, route tables, igw

2. RDS Database instance, Postgres 12.5 within the private subnet

3. Bastion server securely accessing the database or other services

4. ALB (Application Load Balancer) for handing routing and SSL

5. ECS (Elastice Container Service) cluster, using EC2 instances as the capacity provider

6. Your applications, as deployed using task & container defintions as services on the ECS Cluster

7. ACM Certificate to enable HTTPs/SSL for your application

8. Route 53 (DNS), only available if the domain is also hosted in R53
    - CNAME record for ALB
    - A record for Bastion server

9. IAM user to enable Github Actions for CI/CD

## Requirements

1. AWS access/credentials
    - It's reccommeneded to have Administrator access to ensure proper permisions
    - [Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

2. Binaries
    - [Terraform >=v0.14](https://www.terraform.io/downloads.html)

3. Terraform State and Lock files requires pre-created resources [Documentation](https://www.terraform.io/docs/language/settings/backends/s3.html)
    - S3 Bucket for storing state file
    - DynamoDB Table for storing lock files (recommended default: terraform-locks)
    - see examples folder for how to properly set

## Example

See examples folder

## Inputs
### General
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | The overall name of the project using this infrastructure; used to group related resources by | `string` | n/a | yes |
| account_id | the aws account id # that this is provisioned into | `string` | n/a | yes |
| environment | a short name describing the lifecyle or stage of development that this is running for; ex: 'dev', 'stage', 'prod' | `string` | n/a | yes |
| region | the AWS region; ex: 'us-west-2', 'us-east-1', 'us-east-2' | `string` | n/a | yes |
| tags| key value map of tags applied to infrastructure | `map(string)` | `{terraform_managed = "true"}` | no |

### Networking
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr |The range of IP range this vpc will reside in | `string` | `"10.10.0.0/16"` | no |
| domain_name | The domain name where the application will be deployed, must already be hosted in AWS | `string` | `""` | no |
| host_names | The URL(s) where the application will be hosted, must be a subdomain of the domain_name | `string` | `[""]` | no |
| bastion_hostname | Hostname for the Bastion server | `string` | `""` | no |
| default_alb_url | Default redirect for requests to the ALB | `string` | n/a | yes |

### Compute
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key_name | Pre-created Key Pair created in EC2 Console| `string` | `""` | no |
| ecs_ec2_instance_count | Number of ECS EC2 instances to start with | `number` | 0 | no |

### Database
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_db_instance | Flag whether to create DB Instance | `string` | 'false' | no |
| db_username | The name of the default postgres user created by RDS when the instance is booted | `string` | n/a | yes |
| db_password | The postgres database password created for the default database when the instance is booted. :warning: do not put this into git!| `string` | n/a | yes |
| db_instance_class | The name of the default postgres user created by RDS when the instance is booted | `string` | `"t3.small"` | no |
| db_engine_version | The name of the default postgres user created by RDS when the instance is booted | `string` | `"12.5"` | no |
| db_major_version | The name of the default postgres user created by RDS when the instance is booted | `string` | `"12"` | no |
| db_snapshot_migration | Name of database snapshot to start the DB with, must be within the same region, must be same DB Engine/Version | `string` | `""` | no |


### CICD ( flag not created yet )
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cicd_user | Flag to create an AWS IAM User for integrating CI/CD | `string` | `true` | no |


#### Bastion
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion_github_file | file within a repo for allowing SSH access; see below for more info | `map(string)` | n/a | yes |
| bastion_instance_type | Instance Type for bastion server | `string` | `t2.micro` | no |

## Bastion server
A [bastion server](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/overview.html)
is a hardened server through which access to resources running in private
subnets of a VPC. An example use case is a database. Rather than create a
database with ports open to the whole wide Internet we can create it within our
own virtual cloud, and grant access to it via the bastion, aka "jumpbox", server.

To grant users access via the bastion to VPC resources add the user's Github Username to the file you marked as input. A cron job is configured to run to retrieve the user's key and create their account on the bastion server.
Supply the file via the input: var.bastion_github_file
example:
``` hcl
variable "bastion_github_file"  = {
    github_repo_owner = "100Automations",
    github_repo_name  = "incubator",
    github_branch     = "main",
    github_filepath   = "bastion_github_users",
}
```
``` bash
# List of Github Users allowed to access the bastion server
#
darpham
# END OF FILE
```

SSH command:
```bash
ssh -i ~/.ssh/<user-private-github-key> <user-github-name>@<bastion-hostname>
```

# TODO
- [ ] Update Inputs
- [ ] ...
