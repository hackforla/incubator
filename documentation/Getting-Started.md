## Requirements

1. AWS access/credentials
    - It's reccommeneded to have Administrator access to ensure proper permisions
    - [Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

2. Binaries
    - [Terraform >=v0.14](https://www.terraform.io/downloads.html)
    - [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

3. Domain Registered in AWS Route53

3. Terraform State and Lock files requires pre-created resources [Documentation](https://www.terraform.io/docs/language/settings/backends/s3.html)
    - S3 Bucket for storing state file
    - DynamoDB Table for storing lock files (recommended default: terraform-locks)
    - see examples folder for how to properly set
