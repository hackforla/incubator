# Adopts the two civictechindex ECR repositories, which predate the Terraform
# rewrite and were never brought into state. See hackforla/incubator#165.
import {
  to = module.civic-tech-index.module.ecr_backend_prod.aws_ecr_repository.this
  id = "civictechindex-backend-prod"
}

import {
  to = module.civic-tech-index.module.ecr_backend_stage.aws_ecr_repository.this
  id = "civictechindex-backend-stage"
}

# Adopts the civictechindex.org production frontend bucket. In AWS provider v4 and
# later the website configuration, policy and public access block are each their own
# resource, so each needs its own import. See hackforla/incubator#165.
import {
  to = module.civic-tech-index.aws_s3_bucket.website
  id = "civictechindex.org"
}

import {
  to = module.civic-tech-index.aws_s3_bucket_website_configuration.website
  id = "civictechindex.org"
}

import {
  to = module.civic-tech-index.aws_s3_bucket_public_access_block.website
  id = "civictechindex.org"
}

import {
  to = module.civic-tech-index.aws_s3_bucket_policy.website
  id = "civictechindex.org"
}

# Adopts the home-unite-us production Cognito stack. The `Home Unite Us` pool carries
# the live user accounts and its ids are baked into the running production image, so
# it is imported in place rather than rebuilt. The QA pool in cognito-qa.tf is a
# separate pool and is untouched by these. See hackforla/incubator#166.
import {
  to = module.home-unite-us.aws_cognito_user_pool.homeuniteus_prod
  id = "us-west-2_VH24AGQ3p"
}

import {
  to = module.home-unite-us.aws_cognito_user_pool_client.homeuniteus_prod
  id = "us-west-2_VH24AGQ3p/b76g3q852lb4us1rbo19he3uj"
}

import {
  to = module.home-unite-us.aws_cognito_user_pool_domain.homeuniteus_prod
  id = "homeuniteus"
}

# The four user groups come in through a single for_each block. Terraform honours
# only one import block per resource address, so four separate static blocks left
# three of the groups unimported and planned as creates against groups that already
# exist. The fifth group on the pool, us-west-2_VH24AGQ3p_Google, is created
# automatically by Cognito for federated users and is deliberately not declared.
import {
  for_each = toset(["Hosts", "Guests", "Coordinators", "Admins"])
  to       = module.home-unite-us.aws_cognito_user_group.homeuniteus_prod[each.key]
  id       = "us-west-2_VH24AGQ3p/${each.key}"
}

import {
  to = module.home-unite-us.aws_cognito_identity_provider.google_client_prod
  id = "us-west-2_VH24AGQ3p:Google"
}

# The pool's sms_configuration references this role, so it has to come into state
# alongside the pool. The inline policy id is role_name:policy_name.
import {
  to = module.home-unite-us.aws_iam_role.cognito_idp_prod
  id = "homeuniteus-cognito-idp"
}

import {
  to = module.home-unite-us.aws_iam_role_policy.cognito_sns_prod
  id = "homeuniteus-cognito-idp:homeuniteus-cognito-idp"
}

import {
  to = module.home-unite-us.aws_secretsmanager_secret.cognito_client_prod
  id = "arn:aws:secretsmanager:us-west-2:035866691871:secret:homeuniteus-cognito-client-EEaiW4"
}

# Adopts the production image repository. It is declared as a plain resource in
# projects/home-unite-us/ecr.tf rather than through modules/ecr, because the module
# would rename it. See hackforla/incubator#166.
import {
  to = module.home-unite-us.aws_ecr_repository.homeuniteus_prod
  id = "homeuniteus"
}

# Adopts the ballotnav.org hosted zone and its five records. Importing a zone does
# not import its records, and a record that already exists cannot be created --
# allow_overwrite defaults to false -- so each record needs its own import.
# See hackforla/incubator#183.
import {
  to = module.ballotnav.aws_route53_zone.this
  id = "Z07523651NOVLWMBAS3IL"
}

import {
  to = module.ballotnav.aws_route53_record.apex
  id = "Z07523651NOVLWMBAS3IL_ballotnav.org_A"
}

# One block per resource address, not per instance -- four static blocks would
# import one and plan the other three as creates.
import {
  for_each = toset(["about", "admin", "demo", "www"])
  to       = module.ballotnav.aws_route53_record.pages[each.key]
  id       = "Z07523651NOVLWMBAS3IL_${each.key}.ballotnav.org_CNAME"
}
