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