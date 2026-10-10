# The security group and its rules gained count when bridge mode was added
# (hackforla/incubator#252). Without these, every existing awsvpc service would plan to
# destroy and recreate them.

moved {
  from = aws_security_group.container
  to   = aws_security_group.container[0]
}

moved {
  from = aws_vpc_security_group_ingress_rule.container_ingress_port
  to   = aws_vpc_security_group_ingress_rule.container_ingress_port[0]
}

moved {
  from = aws_vpc_security_group_egress_rule.allow_all_traffic
  to   = aws_vpc_security_group_egress_rule.allow_all_traffic[0]
}
