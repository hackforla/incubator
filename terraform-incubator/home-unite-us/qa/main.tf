terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    region = "us-west-2"
    key    = "incubator/home-unite-us/qa-tmp.tfstate"
    bucket = "hlfa-incubator-terragrunt"
  }
}

locals {
    developers = [
        "mugdh.chauhan",
        "jack.pashayan"
    ]
}

resource "aws_iam_user" "developer" {
    for_each = toset(local.developers)
    name          = each.value
    path          = "/"
    force_destroy = true
}

resource "aws_iam_user_login_profile" "developer" {
    for_each = toset(local.developers)
    user    = aws_iam_user.developer[each.key].name
    pgp_key = file("./public.asc")
}

output "dev_pw_mugdh" {
  value = aws_iam_user_login_profile.developer["mugdh.chauhan"].encrypted_password
}

output "dev_pw_jack" {
  value = aws_iam_user_login_profile.developer["jack.pashayan"].encrypted_password
}