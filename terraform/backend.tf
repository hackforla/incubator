terraform {
  # Pins major and minor; patch releases are still picked up. A two-part
  # constraint like "~> 1.12" allows every 1.x, which is how CI drifted from
  # 1.12 to 1.16 unnoticed. The dflook plan/apply actions resolve this to the
  # latest matching release, so this line alone chooses the CI Terraform version.
  required_version = "~> 1.16.0"
  backend "s3" {
  }
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }
}

provider "postgresql" {
  host            = var.pghost
  port            = 5432
  database        = "postgres"
  username        = "postgres"
  password        = var.pgpassword
  sslmode         = "require"
  connect_timeout = 15
  superuser = false
}

provider "aws" {
  default_tags {
    tags = {
      managed-by = "terraform-incubator"
    }
  }
}
