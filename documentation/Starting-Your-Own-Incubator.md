## Requirements

1. AWS access/credentials
    - It's recommended to have Administrator access to ensure proper permissions
    - [Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

2. Binaries
    - [Terraform >=v0.14](https://www.terraform.io/downloads.html)
    - [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

3. Hosted Zone in AWS Route53 via 2 methods
    - Have a domain registered in AWS
        - [Register a new domain](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html)
        - [Transfer domain registration to Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-transfer-to-route-53.html)
    - [Configure Route53 as your DNS service](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/migrate-dns-domain-in-use.html)

4. Terraform State and Lock files requires pre-created resources [Documentation](https://www.terraform.io/docs/language/settings/backends/s3.html)
    - S3 Bucket for storing state file
    - DynamoDB Table for storing lock files (recommended default: terraform-locks)
    - see examples folder for how to properly set

5. Database Credentials for RDS Database, create file in
`REPO_ROOT/incubator/rds.hcl`
```
locals {
  db_username="postgres"
  db_password="super-secret-password"
}
```
