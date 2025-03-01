module "people-depot" {
    source = "./projects/people-depot"
}

module "civic-tech-jobs" {
    source = "./projects/civic-tech-jobs"
}

module "home-unite-us" {
    source = "./projects/home-unite-us"
}


data "aws_caller_identity" "current" {}
