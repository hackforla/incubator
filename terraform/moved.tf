moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_viewer_username.aws_ssm_parameter.this
    to = module.people-depot.module.dev_database.module.db_viewer_username.aws_ssm_parameter.this
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_viewer_password.random_password.password
    to = module.people-depot.module.dev_database.module.db_viewer_password.random_password.password
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_viewer_password.aws_ssm_parameter.this
    to = module.people-depot.module.dev_database.module.db_viewer_password.aws_ssm_parameter.this
}

moved {
  from = module.people-depot.module.people_depot_dev_database.module.db_user_username.aws_ssm_parameter.this
  to = module.people-depot.module.dev_database.module.db_user_username.aws_ssm_parameter.this
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_viewer_username.random_password.password
    to = module.people-depot.module.dev_database.module.db_viewer_username.random_password.password
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_user_username.random_password.password
    to = module.people-depot.module.dev_database.module.db_user_username.random_password.password
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_user_password.random_password.password
    to = module.people-depot.module.dev_database.module.db_user_password.random_password.password
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_user_password.aws_ssm_parameter.this
    to = module.people-depot.module.dev_database.module.db_user_password.aws_ssm_parameter.this
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_owner_username.random_password.password
    to = module.people-depot.module.dev_database.module.db_owner_username.random_password.password
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_owner_username.aws_ssm_parameter.this
    to = module.people-depot.module.dev_database.module.db_owner_username.aws_ssm_parameter.this
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_owner_password.random_password.password
    to = module.people-depot.module.dev_database.module.db_owner_password.random_password.password
}

moved {
    from = module.people-depot.module.people_depot_dev_database.module.db_owner_password.aws_ssm_parameter.this
    to = module.people-depot.module.dev_database.module.db_owner_password.aws_ssm_parameter.this
}

moved {
    from = module.people-depot.module.people_depot_dev_database.postgresql_role.db_viewer
    to = module.people-depot.module.dev_database.postgresql_role.db_viewer
}

moved {
    from = module.people-depot.module.people_depot_dev_database.postgresql_role.db_user
    to = module.people-depot.module.dev_database.postgresql_role.db_user
}

moved {
    from = module.people-depot.module.people_depot_dev_database.postgresql_role.db_owner
    to = module.people-depot.module.dev_database.postgresql_role.db_owner
}

moved {
    from = module.people-depot.module.people_depot_dev_database.postgresql_grant.viewer
    to = module.people-depot.module.dev_database.postgresql_grant.viewer
}

moved {
    from = module.people-depot.module.people_depot_dev_database.postgresql_grant.user
    to = module.people-depot.module.dev_database.postgresql_grant.user
}

moved {
    from = module.people-depot.module.people_depot_dev_database.postgresql_database.db
    to = module.people-depot.module.dev_database.postgresql_database.db
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_vpc_security_group_ingress_rule.container_ingress_port
    to = module.people-depot.module.backend_dev_service.aws_vpc_security_group_ingress_rule.container_ingress_port
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_vpc_security_group_egress_rule.allow_all_traffic
    to = module.people-depot.module.backend_dev_service.aws_vpc_security_group_egress_rule.allow_all_traffic
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_security_group.container
    to = module.people-depot.module.backend_dev_service.aws_security_group.container
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_lb_target_group.this
    to = module.people-depot.module.backend_dev_service.aws_lb_target_group.this
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_lb_listener_rule.static
    to = module.people-depot.module.backend_dev_service.aws_lb_listener_rule.static
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_iam_role_policy_attachment.task_policy
    to = module.people-depot.module.backend_dev_service.aws_iam_role_policy_attachment.task_policy
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_iam_role.instance
    to = module.people-depot.module.backend_dev_service.aws_iam_role.instance
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_iam_policy.container_policy
    to = module.people-depot.module.backend_dev_service.aws_iam_policy.container_policy
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_ecs_task_definition.task
    to = module.people-depot.module.backend_dev_service.aws_ecs_task_definition.task
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_ecs_service.fargate
    to = module.people-depot.module.backend_dev_service.aws_ecs_service.fargate
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_service.aws_cloudwatch_log_group.this
    to = module.people-depot.module.backend_dev_service.aws_cloudwatch_log_group.this
}

moved {
    from = module.people-depot.module.people_depot_backend_stage_dns_entry.aws_route53_record.www
    to = module.people-depot.module.dev_dns_entry.aws_route53_record.www
}

moved {
    from = module.people-depot.module.people_depot_backend_dev_api_secret.random_password.password
    to = module.people-depot.module.backend_dev_api_secret.random_password.password
}

moved {
    from = module.people-depot.module.people_depot_backend_dev_api_secret.aws_ssm_parameter.this
    to = module.people-depot.module.backend_dev_api_secret.aws_ssm_parameter.this
}
# The ACM validation records were declared standalone in each project's dns.tf by
# hackforla/incubator#183, because the certificates themselves were not in Terraform. They
# now belong to the acm-certificate module. Moving rather than replacing matters: deleting a
# validation record does not break TLS today, it stops the certificate renewing, and that
# only surfaces as an expiry up to a year later. See hackforla/incubator#185.
#
# The keys are the validation record names as ACM reports them, trailing dot included.
moved {
    from = module.vrms.aws_route53_record.cert_validation
    to   = module.vrms.module.certificate.aws_route53_record.validation["_ae6574e1afa9e171d1634c7d7df55699.vrms.io."]
}

moved {
    from = module.home-unite-us.aws_route53_record.cert_validation
    to   = module.home-unite-us.module.certificate.aws_route53_record.validation["_5bb55cc568d53bab04232d9f9e534189.homeunite.us."]
}

moved {
    from = module.civic-tech-index.aws_route53_record.cert_validation
    to   = module.civic-tech-index.module.certificate.aws_route53_record.validation["_9aed66007870880679080f7176758008.civictechindex.org."]
}

# Only the stage certificate moves. The apex certificate is deleted, so its validation
# record is destroyed rather than moved -- see projects/civic-tech-jobs/dns.tf.
moved {
    from = module.civic-tech-jobs.aws_route53_record.cert_validation_stage
    to   = module.civic-tech-jobs.module.certificate_stage.aws_route53_record.validation["_1ca49dd660678abe9478619c13875864.stage.civictechjobs.org."]
}
