// Production for home-unite-us.
//
// This stands the production stack up ALONGSIDE the existing unmanaged `homeuniteus`
// service rather than replacing it. Its listener rule sits at priority 17 and the live
// one at 16; the load balancer evaluates the lower number first, so nothing here takes
// traffic until rule 16 is removed. That cutover, and deleting the old stack, is a
// separate change. See hackforla/incubator#166.

data "aws_db_instance" "shared_prod" {
  db_instance_identifier = "incubator-prod-database"
}

// The production database predates Terraform and is not created here -- it already
// exists inside the shared instance, with its password in a Secrets Manager secret
// left behind by the Terragrunt stack. Only the assembled connection string is stored,
// as an SSM parameter, matching how the QA environment passes DATABASE_URL.
data "aws_secretsmanager_secret_version" "rds_password_prod" {
  secret_id = "homeuniteus-rds-password"
}

module "db_url_prod" {
  source           = "../../modules/secret"
  project_name     = local.project_name
  application_type = "fullstack"
  environment      = "prod"
  name             = "database_url"
  value            = "postgresql+psycopg2://homeuniteus:${data.aws_secretsmanager_secret_version.rds_password_prod.secret_string}@${data.aws_db_instance.shared_prod.address}:${data.aws_db_instance.shared_prod.port}/homeuniteus"
}

module "prod_service" {
  source           = "../../modules/container"
  project_name     = local.project_name
  environment      = "prod"
  application_type = "fullstack"

  launch_type = "ec2"

  container_port = 80

  // Sized to match what the unmanaged service runs today.
  container_cpu                = 256
  container_memory             = 512
  container_memory_reservation = 512

  // The tag production is already serving. It is date-and-SHA stamped rather than a
  // moving tag like `:qa`, so it cannot drift the way the mutable tags elsewhere in
  // this account have. Building a fresh production image is being handled separately
  // with the HomeUniteUs team.
  container_image = "${aws_ecr_repository.homeuniteus_prod.repository_url}:2dc864ae50.20250220-172003"

  // Every value the application needs is set here explicitly. The image carries a
  // baked-in .env file with the same keys; environment variables take precedence over
  // it, so declaring the full set is what stops production depending on a file nobody
  // can read. These point at the production Cognito pool imported in cognito-prod.tf,
  // NOT the QA pool in cognito-qa.tf.
  container_environment = [
    // The image is built with HUU_TARGET_ENV=qa, which bakes /var/www/qa.homeunite.us
    // and /var/log/qa.homeunite.us into it, so this must stay "qa" while that tag is
    // in use. It is not a copy-paste error from the QA environment.
    { "name" : "HUU_ENVIRONMENT", "value" : "qa" },
    { "name" : "APP_ENVIRONMENT", "value" : "DEV" },
    { "name" : "COGNITO_CLIENT_ID", "value" : aws_cognito_user_pool_client.homeuniteus_prod.id },
    { "name" : "COGNITO_CLIENT_SECRET", "value" : aws_cognito_user_pool_client.homeuniteus_prod.client_secret },
    { "name" : "COGNITO_REGION", "value" : "us-west-2" },
    { "name" : "COGNITO_REDIRECT_URI", "value" : "https://qa.homeunite.us/signin" },
    { "name" : "COGNITO_USER_POOL_ID", "value" : aws_cognito_user_pool.homeuniteus_prod.id },
    { "name" : "COGNITO_ENDPOINT_URL", "value" : "https://homeuniteus.auth.us-west-2.amazoncognito.com" },
    // Left empty deliberately so boto3 falls back to the task role below, rather than
    // the static access key of the homeuniteus-app IAM user that the baked .env uses.
    // Retiring that user and its key is part of the cleanup change.
    { "name" : "COGNITO_ACCESS_ID", "value" : "" },
    { "name" : "COGNITO_ACCESS_KEY", "value" : "" },
    // The frontend bundle is compiled with VITE_HUU_API_BASE_URL=https://qa.homeunite.us/api,
    // so the backend's ROOT_URL has to agree with it or the OAuth redirect breaks.
    { "name" : "ROOT_URL", "value" : "https://qa.homeunite.us" },
    { "name" : "LOG_LEVEL", "value" : "INFO" }
  ]

  container_environment_secrets = [
    { "name" : "DATABASE_URL", "valueFrom" : module.db_url_prod.arn },
  ]

  // Both hostnames are served by one rule, matching the unmanaged rule at priority 16.
  // www is the public name; qa is what the image's baked URLs point at, so the auth
  // flow needs it until a rebuilt image moves them to www.
  hostname             = "qa.homeunite.us"
  additional_host_urls = ["www.homeunite.us"]
  path                 = "/*"

  listener_priority = 17
}

resource "aws_iam_role_policy_attachment" "prod_cognito" {
  role       = module.prod_service.task_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}
