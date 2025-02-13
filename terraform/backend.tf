terraform {
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