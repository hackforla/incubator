locals {
  // we use tf to create the zone, but other projects might
  // have an existing zone and get it with a data block
  zone_id = module.zone.zone_id

  envs = {
    dev = {
      environment = "dev"
      db_name     = "access-the-data-dev"
      host_names  = ["dev"]
      container_env = {
        CKAN_SITE_URL = "https://dev.accessthedata.org"
      }
    }
  }
}

module "zone" {
  source = "../../terraform-modules/project-zone"

  zone_name            = "accessthedata.org"
  shared_configuration = local.shared_configuration
}

module "database" {
  for_each = local.envs

  source = "../../terraform-modules/database"

  environment = each.value.environment
  db_name     = each.value.db_name
  username    = "ckan"
}

module "secrets" {
  for_each     = local.envs
  source       = "../../terraform-modules/cheap-secrets"
  scope-name   = "ckan-${each.value}"
  secret-names = ["csrf", "admin-password"]
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
      tag    = "latest"
      cpu    = 256
      memory = 512
      port   = 80

      subdomains    = each.value.host_names
      path_patterns = ["/*"]
      env_vars = merge({
        DATABASE      = "postgres"
        POSTGRES_HOST = module.database.host
        POSTGRES_PORT = module.database.port

        // SQLALCHEMY has been set up in the container =
        // we don't know the PG password, so we can't build the URLs

        # Taken verbatim from .env
        CKAN_DB      = module.database.database
        CKAN_DB_USER = module.database.user
        CKAN_VERSION = "2.10.0"
        CKAN_SITE_ID = "default"

        CKAN_PORT      = "5000"
        CKAN_PORT_HOST = "5000"

        CKAN_SYSADMIN_NAME  = "ckan_admin"
        CKAN_SYSADMIN_EMAIL = "your_email@example.com"
        CKAN_STORAGE_PATH   = "/var/lib/ckan"

        CKAN_SMTP_SERVER    = "smtp.hackforla.org:25"
        CKAN_SMTP_STARTTLS  = "True"
        CKAN_SMTP_USER      = "user"
        CKAN_SMTP_PASSWORD  = "pass"
        CKAN_SMTP_MAIL_FROM = "ckan@localhost"

        CKAN_SOLR_URL                       = "http://solr:8983/solr/ckan"
        CKAN_REDIS_URL                      = "redis://redis:6379/1"
        CKAN_DATAPUSHER_URL                 = "http://datapusher:8800"
        CKAN__DATAPUSHER__CALLBACK_URL_BASE = "http://ckan:5000"
        CKAN__HARVEST__MQ__HOSTNAME         = "redis"

        CKAN__PLUGINS               = "envvars image_view text_view recline_view datastore datapusher ckanext_hack4laatd"
        CKAN__HARVEST__MQ__TYPE     = "redis"
        CKAN__HARVEST__MQ__PORT     = "6379"
        CKAN__HARVEST__MQ__REDIS_DB = "1"
        CKAN__FAVICON               = "favicon.png"
      }, lookup(each.value.container_env, "ckan", {}))
      secrets = {
        CKAN_DB_PASSWORD               = module.databse.password_arn
        CKAN___BEAKER__SESSION__SECRET = module.secrets["ckan-${each.value}"].arn["csrf"]
        CKAN_SYSADMIN_PASSWORD         = module.secrets["ckan-${each.value}"].arn["admin-password"]
      }
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
}
