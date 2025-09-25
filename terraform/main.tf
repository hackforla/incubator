module "people-depot" {
    source = "./projects/people-depot"
}

module "civic-tech-jobs" {
    source = "./projects/civic-tech-jobs"
}

module "home-unite-us" {
    source = "./projects/home-unite-us"
}

module "vrms" {
    source = "./projects/vrms"
}

module "civic-tech-index" {
    source = "./projects/civic-tech-index"
}




data "aws_caller_identity" "current" {}
