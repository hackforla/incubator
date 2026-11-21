// postgis for neighborhood lookups (ST_* functions); earthdistance for location search,
// which uses its point <@> point operator. earthdistance brings cube with it, so cube is
// not listed. No Food Oasis migration creates either of the last two.
module "food_oasis_prod_database" {
  source           = "../../modules/database"
  project_name     = local.project_name_food_oasis
  application_type = "fullstack"
  environment      = "prod"
  extensions       = ["postgis", "earthdistance"]
}

// Signs login tokens. A new value rather than Heroku production's, which signs everyone out
// at cutover. Stored in SSM so the container reads it as a secret; the execution role can
// read /food-oasis/*.
module "food_oasis_prod_jwt_secret" {
  source           = "../../modules/secret"
  project_name     = local.project_name_food_oasis
  application_type = "fullstack"
  environment      = "prod"
  name             = "jwt-secret"
}

// Production for every region under both domains, bare domains included. Configured as
// staging, apart from the image, place index, CORS, database and hosts.
//
// Priority 601 must stay higher than staging's 600, so staging's dev* names match first.
// Until hackforla/devops#238, the bare foodoasis.la still matches rule 599's redirect to
// www, and the bare foodoasis.net still points at Amplify.
//
// The image does not run migrations at startup; the Food Oasis team runs them, as _owner,
// which is why the app connects as _owner too.
module "food_oasis_fullstack_prod_service" {
  source           = "../../modules/container"
  project_name     = local.project_name_food_oasis
  environment      = "prod"
  application_type = "fullstack"

  launch_type  = "ec2"
  network_mode = "bridge"

  container_port    = 5001
  health_check_path = "/health"
  container_image   = "${module.food_oasis_ecr_fullstack.repository_url}:prod"

  // As in staging: with NODE_ENV=production, /health answers the load balancer's plain-HTTP
  // check with a 302 to HTTPS. Without this, ECS replaces the task every few minutes.
  health_check_matcher = "200,302"

  // Do not set DATABASE_URL, which overrides POSTGRES_*. Do not set AWS_ACCESS_KEY_ID,
  // AWS_SECRET_ACCESS_KEY, AWS_PROFILE or IDENTITY_POOL_ID: the SDK's default credential
  // chain checks keys and profile before the task role, and IDENTITY_POOL_ID switches
  // address search to Cognito (hackforla/incubator#277).
  //
  // No CORS_ALLOWED_ORIGINS: Heroku production sets none, because the client is served from
  // the same origin as the API (hackforla/devops#236).
  container_environment = [
    // Heroku set NODE_ENV=production implicitly; here it must be explicit.
    { "name" : "NODE_ENV", "value" : "production" },
    { "name" : "PORT", "value" : "5001" },

    { "name" : "POSTGRES_HOST", "value" : module.food_oasis_prod_database.host },
    { "name" : "POSTGRES_PORT", "value" : module.food_oasis_prod_database.port },
    { "name" : "POSTGRES_DATABASE", "value" : module.food_oasis_prod_database.database },
    { "name" : "POSTGRES_USERNAME", "value" : module.food_oasis_prod_database.owner_username },
    // incubator-prod-database sets rds.force_ssl = 1. The app uses SSL unless this is "false".
    { "name" : "POSTGRES_SSL", "value" : "true" },

    { "name" : "AWS_REGION", "value" : "us-west-2" },
    { "name" : "PLACE_INDEX_NAME", "value" : aws_location_place_index.this["prod"].index_name },

    // Heroku production's values, which match staging's.
    { "name" : "EMAIL_USER", "value" : "donotreply@foodoasis.net" },
    { "name" : "CONTACT_US_LA", "value" : "foodoasis@hackforla.org" },
    { "name" : "CONTACT_US_HAWAII", "value" : "info@alohaharvest.org" },
  ]
  container_environment_secrets = [
    { "name" : "POSTGRES_PASSWORD", "valueFrom" : module.food_oasis_prod_database.owner_password_arn },
    { "name" : "JWT_SECRET", "valueFrom" : module.food_oasis_prod_jwt_secret.arn },
  ]

  // With the path condition that is five values, the most one listener rule takes.
  hostname             = "*.foodoasis.net"
  additional_host_urls = ["foodoasis.net", "*.foodoasis.la", "foodoasis.la"]
  path                 = "/*"

  listener_priority = 601
}

// Email through SES as donotreply@foodoasis.net.
module "food_oasis_prod_ses" {
  source         = "../../modules/ses-container-permissions"
  name           = "food-oasis-prod-ses-send"
  task_role_name = module.food_oasis_fullstack_prod_service.task_role_name
  identity_arns  = [module.ses_foodoasis_net.arn]

  tags = {
    project = local.project_name_food_oasis
  }
}

// Address search on the prod place index.
resource "aws_iam_role_policy_attachment" "food_oasis_prod_location" {
  role       = module.food_oasis_fullstack_prod_service.task_role_name
  policy_arn = aws_iam_policy.location_search["prod"].arn
}
