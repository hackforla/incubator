moved {
  from = aws_appautoscaling_policy.ecs_autoscale_cpu
  to   = module.prod.module.vrms-client.aws_appautoscaling_policy.ecs_autoscale_cpu
}
moved {
  from = aws_appautoscaling_policy.ecs_autoscale_memory
  to   = module.prod.module.vrms-client.aws_appautoscaling_policy.ecs_autoscale_memory
}
moved {
  from = aws_appautoscaling_target.ecs_target
  to   = module.prod.module.vrms-client.aws_appautoscaling_target.ecs_target
}
moved {
  from = aws_lb_listener_rule.static
  to   = module.prod.module.vrms-client.aws_lb_listener_rule.static
}
moved {
  from = aws_lb_target_group.this
  to   = module.prod.module.vrms-client.aws_lb_target_group.this
}
moved {
  from = aws_security_group.fargate
  to   = module.prod.module.vrms-client.aws_security_group.fargate
}
moved {
  from = aws_cloudwatch_log_group.cwlogs
  to   = module.prod.module.vrms-client.aws_cloudwatch_log_group.cwlogs
}
moved {
  from = aws_ecs_service.fargate
  to   = module.prod.module.vrms-client.aws_ecs_service.fargate
}
moved {
  from = aws_ecs_task_definition.task
  to   = module.prod.module.vrms-client.aws_ecs_task_definition.task
}
moved {
  from = module.ecr.aws_ecr_repository.this
  to   = module.prod.module.vrms-client.module.ecr.aws_ecr_repository.this
}