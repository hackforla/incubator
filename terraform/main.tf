// The shared platform every project module below runs on. Adopted in hackforla/incubator#184;
// nothing consumes its outputs yet.
module "platform" {
    source = "./platform"
}

module "people-depot" {
    source = "./projects/people-depot"

    // peopledepot-dev.vrms.io sits in a zone the vrms project owns.
    vrms_zone_id = module.vrms.zone_id

    shared_user_pool_id  = aws_cognito_user_pool.shared.id
    shared_user_pool_arn = aws_cognito_user_pool.shared.arn
}

module "civic-tech-jobs" {
    source = "./projects/civic-tech-jobs"
}

module "home-unite-us" {
    source = "./projects/home-unite-us"
}

module "vrms" {
    source = "./projects/vrms"

    shared_user_pool_id  = aws_cognito_user_pool.shared.id
    shared_user_pool_arn = aws_cognito_user_pool.shared.arn
}

module "civic-tech-index" {
    source = "./projects/civic-tech-index"
}

module "ballotnav" {
    source = "./projects/ballotnav"
}

module "three-eleven-data" {
    source = "./projects/311-data"
}

module "access-the-data" {
    source = "./projects/access-the-data"
}




data "aws_caller_identity" "current" {}
