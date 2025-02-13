module "people-depot" {
    source = "./projects/people-depot"
}

data "aws_caller_identity" "current" {}
