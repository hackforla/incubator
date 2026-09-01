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

# Adopts the accessthedata.org hosted zone and its two records. The project has no
# compute left; this module is DNS only. Its ACM validation record was adopted here too
# until hackforla/incubator#185 deleted the certificate. See hackforla/incubator#183.
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

# Adopts the civictechjobs.org hosted zone and the three records not already declared
# by the dns-entry module in environment-stage.tf. The apex certificate's validation record
# was adopted here too until hackforla/incubator#185 deleted that certificate; the stage
# certificate's record moved into the acm-certificate module in the same issue, which is why
# the last block below reads as a module address. See hackforla/incubator#183.
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
  to = module.civic-tech-jobs.module.certificate_stage.aws_route53_record.validation["_1ca49dd660678abe9478619c13875864.stage.civictechjobs.org."]
  id = "Z06949943QJY32WRKG577__1ca49dd660678abe9478619c13875864.stage.civictechjobs.org_CNAME"
}

# Adopts the vrms.io hosted zone and the three records not already declared by the
# dns-entry modules in this project and in people-depot. The validation record moved into
# the acm-certificate module in hackforla/incubator#185. The wildcard *.vrms.io and
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
  to = module.vrms.module.certificate.aws_route53_record.validation["_ae6574e1afa9e171d1634c7d7df55699.vrms.io."]
  id = "Z0420800PGQ9JP6DM9EX__ae6574e1afa9e171d1634c7d7df55699.vrms.io_CNAME"
}

# Adopts the homeunite.us hosted zone and the four records not already declared by the
# dns-entry module in environment-qa.tf. The apex is imported at its current dead value
# (18.223.160.58) and repointed at the load balancer by the apply; dev.homeunite.us held
# the same dead address and is deleted rather than adopted. See the comment in
# projects/home-unite-us/dns.tf and hackforla/incubator#183.
import {
  to = module.home-unite-us.aws_route53_zone.this
  id = "Z03829196Z0VAL9Q8CZ"
}

import {
  to = module.home-unite-us.aws_route53_record.apex
  id = "Z03829196Z0VAL9Q8CZ_homeunite.us_A"
}

import {
  to = module.home-unite-us.aws_route53_record.www
  id = "Z03829196Z0VAL9Q8CZ_www.homeunite.us_CNAME"
}

import {
  to = module.home-unite-us.aws_route53_record.qa
  id = "Z03829196Z0VAL9Q8CZ_qa.homeunite.us_CNAME"
}

import {
  to = module.home-unite-us.module.certificate.aws_route53_record.validation["_5bb55cc568d53bab04232d9f9e534189.homeunite.us."]
  id = "Z03829196Z0VAL9Q8CZ__5bb55cc568d53bab04232d9f9e534189.homeunite.us_CNAME"
}

# Adopts the civictechindex.org hosted zone and four of its records. This project uses
# no dns-entry module, so nothing in the zone was previously managed.
# stage.api.civictechindex.org and test.civictechindex.org are deliberately not
# adopted -- both are deleted, see the comment in projects/civic-tech-index/dns.tf.
# See hackforla/incubator#183.
import {
  to = module.civic-tech-index.aws_route53_zone.this
  id = "Z06388811ED8NRSEUZU7A"
}

import {
  to = module.civic-tech-index.aws_route53_record.apex
  id = "Z06388811ED8NRSEUZU7A_civictechindex.org_A"
}

import {
  to = module.civic-tech-index.aws_route53_record.api
  id = "Z06388811ED8NRSEUZU7A_api.civictechindex.org_CNAME"
}

import {
  to = module.civic-tech-index.aws_route53_record.api_stage
  id = "Z06388811ED8NRSEUZU7A_api-stage.civictechindex.org_CNAME"
}

import {
  to = module.civic-tech-index.module.certificate.aws_route53_record.validation["_9aed66007870880679080f7176758008.civictechindex.org."]
  id = "Z06388811ED8NRSEUZU7A__9aed66007870880679080f7176758008.civictechindex.org_CNAME"
}

# Adopts the four ACM certificates that survive hackforla/incubator#185. All are
# AMAZON_ISSUED, DNS-validated and in us-west-2. The import id is the full arn.
#
# Two others existed and are not here: civictechjobs.org, which was attached to nothing and
# therefore ineligible for renewal, and accessthedata.org, whose listener attachment was a
# leftover from a project decommissioned in hackforla/incubator#163. Both were deleted
# rather than imported, with captures in the devops workspace's aws-config-backups.
import {
  to = module.vrms.module.certificate.aws_acm_certificate.this
  id = "arn:aws:acm:us-west-2:035866691871:certificate/5f0bd3ee-a6d3-4836-ac82-060756603785"
}

import {
  to = module.home-unite-us.module.certificate.aws_acm_certificate.this
  id = "arn:aws:acm:us-west-2:035866691871:certificate/f7e0693a-4110-41d9-baa5-284ddef95dd4"
}

import {
  to = module.civic-tech-index.module.certificate.aws_acm_certificate.this
  id = "arn:aws:acm:us-west-2:035866691871:certificate/4db5d979-9797-4689-a9e9-58b7ac55c79d"
}

import {
  to = module.civic-tech-jobs.module.certificate_stage.aws_acm_certificate.this
  id = "arn:aws:acm:us-west-2:035866691871:certificate/af0b30d5-0d64-4065-905b-eaced30fe8ba"
}

# Adopts each certificate's attachment to the HTTPS listener, which is a resource in its own
# right rather than an attribute of the certificate. Importing the certificate alone would
# leave the attachment unmanaged and the code would not describe how the listener serves
# TLS. The import id is the listener arn and the certificate arn joined by an underscore.
#
# *.vrms.io is also the listener's DEFAULT certificate. describe-listener-certificates
# returns it twice, once with IsDefault true and once false, so the SNI attachment below is
# a real, separate thing and imports cleanly. The default assignment is an attribute of the
# listener and lands when the load balancer comes into Terraform.
import {
  to = module.vrms.module.certificate.aws_lb_listener_certificate.this[0]
  id = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3_arn:aws:acm:us-west-2:035866691871:certificate/5f0bd3ee-a6d3-4836-ac82-060756603785"
}

import {
  to = module.home-unite-us.module.certificate.aws_lb_listener_certificate.this[0]
  id = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3_arn:aws:acm:us-west-2:035866691871:certificate/f7e0693a-4110-41d9-baa5-284ddef95dd4"
}

import {
  to = module.civic-tech-index.module.certificate.aws_lb_listener_certificate.this[0]
  id = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3_arn:aws:acm:us-west-2:035866691871:certificate/4db5d979-9797-4689-a9e9-58b7ac55c79d"
}

import {
  to = module.civic-tech-jobs.module.certificate_stage.aws_lb_listener_certificate.this[0]
  id = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3_arn:aws:acm:us-west-2:035866691871:certificate/af0b30d5-0d64-4065-905b-eaced30fe8ba"
}

# Adopts the shared platform -- VPC, ECS cluster and its EC2 capacity, load balancer,
# security groups and IAM. All of it carries live production traffic, so the bar is 0 to add,
# 0 to destroy, no replacements, and only the `managed-by` tag changing.
# See hackforla/incubator#184 and terraform/platform/.

import {
  to = module.platform.aws_vpc.this
  id = "vpc-0bec93a4d80243845"
}

# One block per address, not per instance -- static blocks would import one and create the rest.
import {
  for_each = {
    "us-west-2a" = "subnet-03202f3bf9a24c1a5"
    "us-west-2b" = "subnet-08c26edd1afc2b9d7"
  }
  to = module.platform.aws_subnet.public[each.key]
  id = each.value
}

import {
  for_each = {
    "us-west-2a" = "subnet-089e80a53e1522e28"
    "us-west-2b" = "subnet-03ed55f60a6c28e72"
  }
  to = module.platform.aws_subnet.private[each.key]
  id = each.value
}

import {
  to = module.platform.aws_internet_gateway.this
  id = "igw-08a3f5ac4b9b95fe6"
}

# An elastic IP imports by allocation id.
import {
  to = module.platform.aws_eip.nat
  id = "eipalloc-06bfab9d37e03e354"
}

import {
  to = module.platform.aws_nat_gateway.this
  id = "nat-08bd5eb6d8b6bdcb7"
}

import {
  to = module.platform.aws_route_table.public
  id = "rtb-025f1f7a71186c7db"
}

import {
  for_each = {
    "us-west-2a" = "rtb-0ea3b47efe34847f0"
    "us-west-2b" = "rtb-0a61d387aacfe12ca"
  }
  to = module.platform.aws_route_table.private[each.key]
  id = each.value
}

# Imports by VPC id, not route table id -- the provider looks the main table up by filter.
# rtb-0d31f54d4ef4ee74c is the table this resolves to.
import {
  to = module.platform.aws_default_route_table.main
  id = "vpc-0bec93a4d80243845"
}

# A route table association imports by subnet_id/route_table_id.
import {
  for_each = {
    "us-west-2a" = "subnet-03202f3bf9a24c1a5/rtb-025f1f7a71186c7db"
    "us-west-2b" = "subnet-08c26edd1afc2b9d7/rtb-025f1f7a71186c7db"
  }
  to = module.platform.aws_route_table_association.public[each.key]
  id = each.value
}

import {
  for_each = {
    "us-west-2a" = "subnet-089e80a53e1522e28/rtb-0ea3b47efe34847f0"
    "us-west-2b" = "subnet-03ed55f60a6c28e72/rtb-0a61d387aacfe12ca"
  }
  to = module.platform.aws_route_table_association.private[each.key]
  id = each.value
}

# The cluster imports by name; the capacity provider needs its full arn.
import {
  to = module.platform.aws_ecs_cluster.this
  id = "incubator-prod"
}

import {
  to = module.platform.aws_ecs_capacity_provider.ec2
  id = "arn:aws:ecs:us-west-2:035866691871:capacity-provider/incubator-proc-ec2"
}

# Its own resource, imported by cluster name.
import {
  to = module.platform.aws_ecs_cluster_capacity_providers.this
  id = "incubator-prod"
}

# Imports at latest (8) while default_version is 1. The plan must show no new version.
import {
  to = module.platform.aws_launch_template.ecs
  id = "lt-0093b22d4b048e101"
}

import {
  to = module.platform.aws_autoscaling_group.ecs
  id = "ecs-incubator-prod"
}

import {
  to = module.platform.aws_lb.this
  id = "arn:aws:elasticloadbalancing:us-west-2:035866691871:loadbalancer/app/incubator-prod-lb/7451adf77133ef36"
}

import {
  to = module.platform.aws_lb_listener.https
  id = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3"
}

import {
  to = module.platform.aws_lb_listener.http
  id = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/e3a9e215566b0279"
}

import {
  to = module.platform.aws_security_group.alb
  id = "sg-07dd18f4255a5a5aa"
}

import {
  to = module.platform.aws_vpc_security_group_ingress_rule.alb_http
  id = "sgr-098420814e30df071"
}

import {
  to = module.platform.aws_vpc_security_group_ingress_rule.alb_https
  id = "sgr-01fb2cd6278861ebd"
}

import {
  to = module.platform.aws_vpc_security_group_egress_rule.alb_all
  id = "sgr-0cbc5e41abd60efa4"
}

import {
  to = module.platform.aws_security_group.database
  id = "sg-0ab8947eeb3d705ac"
}

import {
  to = module.platform.aws_vpc_security_group_ingress_rule.database_postgres
  id = "sgr-041beca36c70ef68d"
}

import {
  to = module.platform.aws_vpc_security_group_egress_rule.database_all
  id = "sgr-0aeab91b2988a2025"
}

# Its two rules are not imported separately -- `aws_default_security_group` holds them inline.
import {
  to = module.platform.aws_default_security_group.this
  id = "sg-00bafa5c73e255acd"
}

# Roles and instance profiles import by name, policies by arn, attachments by role/policy-arn.
import {
  to = module.platform.aws_iam_role.ecs_instance
  id = "ecs-ec2-role"
}

import {
  to = module.platform.aws_iam_instance_profile.ecs_instance
  id = "ecs-ec2-role"
}

import {
  to = module.platform.aws_iam_policy.ecs_put_account_settings
  id = "arn:aws:iam::035866691871:policy/ecs-put-account-settings"
}

import {
  to = module.platform.aws_iam_role_policy_attachment.ecs_instance_put_account_settings
  id = "ecs-ec2-role/arn:aws:iam::035866691871:policy/ecs-put-account-settings"
}

import {
  to = module.platform.aws_iam_role_policy_attachment.ecs_instance_ssm_core
  id = "ecs-ec2-role/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

import {
  to = module.platform.aws_iam_role_policy_attachment.ecs_instance_ecs
  id = "ecs-ec2-role/arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

import {
  to = module.platform.aws_iam_role.ecs_task_execution
  id = "incubator-prod-ecs-task-role"
}

import {
  to = module.platform.aws_iam_role_policy_attachment.ecs_task_execution_ecs
  id = "incubator-prod-ecs-task-role/arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

import {
  to = module.platform.aws_iam_role_policy_attachment.ecs_task_execution_ssm
  id = "incubator-prod-ecs-task-role/arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
