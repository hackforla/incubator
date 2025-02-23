module "people-depot" {
    source = "./projects/people-depot"
}

module "civic-tech-jobs" {
    source = "./projects/civic-tech-jobs"
}

data "aws_caller_identity" "current" {}
