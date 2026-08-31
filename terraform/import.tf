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

# Adopts the 311-data.org hosted zone and its two records. The www record is
# imported at its current (broken) value and then changed by the apply; see the
# comment in projects/311-data/dns.tf. See hackforla/incubator#183.
import {
  to = module.three-eleven-data.aws_route53_zone.this
  id = "Z10404141P7IPBA313E5M"
}

import {
  to = module.three-eleven-data.aws_route53_record.apex
  id = "Z10404141P7IPBA313E5M_311-data.org_A"
}

import {
  to = module.three-eleven-data.aws_route53_record.www
  id = "Z10404141P7IPBA313E5M_www.311-data.org_CNAME"
}

# Adopts the accessthedata.org hosted zone and its three records. The project has no
# compute left; this module is DNS only. See hackforla/incubator#183.
import {
  to = module.access-the-data.aws_route53_zone.this
  id = "Z099349812ZUUFQEPL51Q"
}

import {
  to = module.access-the-data.aws_route53_record.apex
  id = "Z099349812ZUUFQEPL51Q_accessthedata.org_A"
}

import {
  to = module.access-the-data.aws_route53_record.apex_ipv6
  id = "Z099349812ZUUFQEPL51Q_accessthedata.org_AAAA"
}

import {
  to = module.access-the-data.aws_route53_record.cert_validation
  id = "Z099349812ZUUFQEPL51Q__0cf1f0f2546b74cb244e41df3c73afe6.accessthedata.org_CNAME"
}

# Adopts the civictechjobs.org hosted zone and the four records not already declared
# by the dns-entry module in environment-stage.tf. See hackforla/incubator#183.
import {
  to = module.civic-tech-jobs.aws_route53_zone.this
  id = "Z06949943QJY32WRKG577"
}

import {
  to = module.civic-tech-jobs.aws_route53_record.apex
  id = "Z06949943QJY32WRKG577_civictechjobs.org_A"
}

import {
  to = module.civic-tech-jobs.aws_route53_record.www
  id = "Z06949943QJY32WRKG577_www.civictechjobs.org_CNAME"
}

import {
  to = module.civic-tech-jobs.aws_route53_record.cert_validation_apex
  id = "Z06949943QJY32WRKG577__a57d306f01d9b44fbca0d00a608ea608.civictechjobs.org_CNAME"
}

import {
  to = module.civic-tech-jobs.aws_route53_record.cert_validation_stage
  id = "Z06949943QJY32WRKG577__1ca49dd660678abe9478619c13875864.stage.civictechjobs.org_CNAME"
}

# Adopts the vrms.io hosted zone and the three records not already declared by the
# dns-entry modules in this project and in people-depot. The wildcard *.vrms.io and
# prod.vrms.io are deliberately not adopted -- both are deleted, see the comment in
# projects/vrms/dns.tf. See hackforla/incubator#183.
import {
  to = module.vrms.aws_route53_zone.this
  id = "Z0420800PGQ9JP6DM9EX"
}

import {
  to = module.vrms.aws_route53_record.apex
  id = "Z0420800PGQ9JP6DM9EX_vrms.io_A"
}

import {
  to = module.vrms.aws_route53_record.www
  id = "Z0420800PGQ9JP6DM9EX_www.vrms.io_CNAME"
}

import {
  to = module.vrms.aws_route53_record.cert_validation
  id = "Z0420800PGQ9JP6DM9EX__ae6574e1afa9e171d1634c7d7df55699.vrms.io_CNAME"
}
