// The staging hostnames, under both domains, pointed at the load balancer, which sends them
// to the staging service below by its dev* host rule. hackforla/devops#237.
//
// Until foodoasis.net's nameservers switch (hackforla/incubator#294), the Food Oasis
// account's zone is the live one, so the .net records here take effect only once they are
// copied into it by hand (hackforla/incubator#284).
locals {
  food_oasis_stage_subdomains = toset(["devla", "devhi", "devmck", "devsb"])
}

module "food_oasis_stage_dns_net" {
  for_each  = local.food_oasis_stage_subdomains
  source    = "../../modules/dns-entry"
  subdomain = each.key
  zone_id   = aws_route53_zone.this.zone_id
}

module "food_oasis_stage_dns_la" {
  for_each  = local.food_oasis_stage_subdomains
  source    = "../../modules/dns-entry"
  subdomain = each.key
  zone_id   = aws_route53_zone.foodoasis_la.zone_id
}

// The .net names were Heroku CNAMEs in dns.tf. Moving them updates each record in place.
// Without this, Terraform would delete the old record and create the new one in no fixed
// order, and Route 53 refuses a create while a record with the same name still exists.
moved {
  from = aws_route53_record.heroku["devla"]
  to   = module.food_oasis_stage_dns_net["devla"].aws_route53_record.www
}

moved {
  from = aws_route53_record.heroku["devhi"]
  to   = module.food_oasis_stage_dns_net["devhi"].aws_route53_record.www
}

moved {
  from = aws_route53_record.heroku["devmck"]
  to   = module.food_oasis_stage_dns_net["devmck"].aws_route53_record.www
}

moved {
  from = aws_route53_record.heroku["devsb"]
  to   = module.food_oasis_stage_dns_net["devsb"].aws_route53_record.www
}

// postgis for neighborhood lookups (ST_* functions); earthdistance for location search,
// which uses its point <@> point operator. earthdistance brings cube with it, so cube is
// not listed. No Food Oasis migration creates either of the last two.
module "food_oasis_stage_database" {
  source           = "../../modules/database"
  project_name     = local.project_name_food_oasis
  application_type = "fullstack"
  environment      = "stage"
  extensions       = ["postgis", "earthdistance"]
}

// Signs login tokens. Stored in SSM so the container reads it as a secret; the execution
// role can read /food-oasis/*.
module "food_oasis_stage_jwt_secret" {
  source           = "../../modules/secret"
  project_name     = local.project_name_food_oasis
  application_type = "fullstack"
  environment      = "stage"
  name             = "jwt-secret"
}

// Staging for every region: devla, devhi, devmck and devsb under both domains. Priority 600
// must stay lower than production's, whose *.foodoasis.net rule would otherwise catch these.
//
// The image does not run migrations at startup; the Food Oasis team runs them, as _owner,
// which is why the app connects as _owner too.
module "food_oasis_fullstack_stage_service" {
  source           = "../../modules/container"
  project_name     = local.project_name_food_oasis
  environment      = "stage"
  application_type = "fullstack"

  launch_type  = "ec2"
  network_mode = "bridge"

  container_port    = 5001
  health_check_path = "/health"
  container_image   = "${module.food_oasis_ecr_fullstack.repository_url}:stage"

  // With NODE_ENV=production the app redirects every request without
  // X-Forwarded-Proto: https to HTTPS, /health included, and the load balancer's health
  // check sends plain HTTP without that header. So /health answers 302 to the check.
  // Accepting 302 only proves the process answers, but without it ECS replaces the task
  // every few minutes. Moving /health above the redirect in hackforla/food-oasis
  // server/server.ts would let this go back to the default.
  health_check_matcher = "200,302"

  // Do not set DATABASE_URL, which overrides POSTGRES_*. Do not set AWS_ACCESS_KEY_ID,
  // AWS_SECRET_ACCESS_KEY, AWS_PROFILE or IDENTITY_POOL_ID: the SDK's default credential
  // chain checks keys and profile before the task role, and IDENTITY_POOL_ID switches
  // address search to Cognito (hackforla/incubator#277).
  container_environment = [
    // Heroku set NODE_ENV=production implicitly; here it must be explicit.
    { "name" : "NODE_ENV", "value" : "production" },
    { "name" : "PORT", "value" : "5001" },

    { "name" : "POSTGRES_HOST", "value" : module.food_oasis_stage_database.host },
    { "name" : "POSTGRES_PORT", "value" : module.food_oasis_stage_database.port },
    { "name" : "POSTGRES_DATABASE", "value" : module.food_oasis_stage_database.database },
    { "name" : "POSTGRES_USERNAME", "value" : module.food_oasis_stage_database.owner_username },
    // incubator-prod-database sets rds.force_ssl = 1. The app uses SSL unless this is "false".
    { "name" : "POSTGRES_SSL", "value" : "true" },

    { "name" : "AWS_REGION", "value" : "us-west-2" },
    { "name" : "PLACE_INDEX_NAME", "value" : aws_location_place_index.this["stage"].index_name },

    { "name" : "EMAIL_USER", "value" : "donotreply@foodoasis.net" },
    { "name" : "CONTACT_US_LA", "value" : "foodoasis@hackforla.org" },
    { "name" : "CONTACT_US_HAWAII", "value" : "info@alohaharvest.org" },
    // Heroku staging's value, unchanged. The client is served from the same origin as the
    // API, so the staging hostnames do not need to be listed.
    { "name" : "CORS_ALLOWED_ORIGINS", "value" : "http://localhost:3000,https://foodoasis.la,https://foodoasis.net,https://la.foodoasis.net,https://sb.foodoasis.net,https://mck.foodoasis.net,https://devla.foodoasis.net" },
  ]
  container_environment_secrets = [
    { "name" : "POSTGRES_PASSWORD", "valueFrom" : module.food_oasis_stage_database.owner_password_arn },
    { "name" : "JWT_SECRET", "valueFrom" : module.food_oasis_stage_jwt_secret.arn },
  ]

  hostname             = "dev*.foodoasis.net"
  additional_host_urls = ["dev*.foodoasis.la"]
  path                 = "/*"

  listener_priority = 600
}

// Email through SES as donotreply@foodoasis.net.
module "food_oasis_stage_ses" {
  source         = "../../modules/ses-container-permissions"
  name           = "food-oasis-stage-ses-send"
  task_role_name = module.food_oasis_fullstack_stage_service.task_role_name
  identity_arns  = [module.ses_foodoasis_net.arn]

  tags = {
    project = local.project_name_food_oasis
  }
}

// Address search on the stage place index.
resource "aws_iam_role_policy_attachment" "food_oasis_stage_location" {
  role       = module.food_oasis_fullstack_stage_service.task_role_name
  policy_arn = aws_iam_policy.location_search["stage"].arn
}
