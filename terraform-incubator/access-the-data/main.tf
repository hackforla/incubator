locals {
  // we use tf to create the zone, but other projects might
  // have an existing zone and get it with a data block
  zone_id = aws_route53_zone.this.zone_id

  zone_name = "accessthedata.org"

  envs = {
    dev = {
      environment   = "dev"
      db_name       = "access-the-data-dev"
      host_names    = ["dev"]
      container_env = {}
    }
  }
}
resource "aws_route53_zone" "this" {
  name = local.zone_name
}

module "access-the-data" {
  for_each = local.envs

  source = "../../terraform-modules/multi-container-service"

  shared_configuration = local.shared_configuration

  region           = "us-west-2"
  project_name     = "access-the-data"
  application_type = "fullstack"
  environment      = each.value.environment
  zone_id          = local.zone_id

  vpc_cidr = "10.10.0.0/16"

  containers = {
    ckan = {
      tag           = "latest"
      cpu           = 256
      memory        = 512
      port          = 80
      db_access     = true
      subdomains    = each.value.host_names
      path_patterns = ["/*"]
      env_vars = merge({
        DATABASE = "postgres"
      }, lookup(each.value.container_env, "ckan", {}))
    }

    datapusher = {
      tag    = "latest"
      cpu    = 256
      memory = 512
    }

    solr = {
      tag    = "latest"
      cpu    = 256
      memory = 512
    }

    redis = {
      tag    = "latest"
      cpu    = 256
      memory = 512
    }
  }

  postgres_database = {
    db_name  = each.value.db_name
    username = "ckan"
  }
}
