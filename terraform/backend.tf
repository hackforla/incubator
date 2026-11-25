terraform {
  # Pins major and minor; patch releases are still picked up. A two-part
  # constraint like "~> 1.12" allows every 1.x, which is how CI drifted from
  # 1.12 to 1.16 unnoticed. The dflook plan/apply actions resolve this to the
  # latest matching release, so this line alone chooses the CI Terraform version.
  required_version = "~> 1.16.0"
  # Locking config lives in terraform/prod.backend.tfvars (use_lockfile).
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.64.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }
}

provider "postgresql" {
  host            = var.pghost
  port            = 5432
  database        = "postgres"
  username        = var.pguser
  password        = var.pgpassword
  sslmode         = "require"
  connect_timeout = 15
  # Keep this false. With it, the provider takes role passwords from state instead of
  # reading pg_shadow, which is what lets the read-only terraform_plan login refresh
  # roles at all.
  #
  # terraform_plan is created by hand, not in Terraform, and has no privileges at all.
  # Everything the provider reads during a refresh is a catalog any login can read
  # (pg_roles, pg_database, pg_extension, and the ACLs in pg_class and pg_namespace).
  # Grant and extension refreshes also connect to each project database, through the
  # CONNECT privilege PostgreSQL gives PUBLIC by default; revoking that from a database
  # breaks the login. See hackforla/incubator#209.
  superuser = false
}

provider "aws" {
  default_tags {
    tags = {
      managed-by = "terraform-incubator"
    }
  }
}
