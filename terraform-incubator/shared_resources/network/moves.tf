moved {
  from = module.vpc.aws_internet_gateway.this[0]
  to   = module.network.module.vpc.aws_internet_gateway.this[0]
}
moved {
  from = module.vpc.aws_route.public_internet_gateway[0]
  to   = module.network.module.vpc.aws_route.public_internet_gateway[0]
}
moved {
  from = module.vpc.aws_subnet.private[0]
  to   = module.network.module.vpc.aws_subnet.private[0]
}
moved {
  from = module.vpc.aws_subnet.private[1]
  to   = module.network.module.vpc.aws_subnet.private[1]
}
moved {
  from = module.vpc.aws_vpc.this[0]
  to   = module.network.module.vpc.aws_vpc.this[0]
}
moved {
  from = module.vpc.aws_route_table.private[0]
  to   = module.network.module.vpc.aws_route_table.private[0]
}
moved {
  from = module.vpc.aws_route_table.private[1]
  to   = module.network.module.vpc.aws_route_table.private[1]
}
moved {
  from = module.vpc.aws_route_table.public[0]
  to   = module.network.module.vpc.aws_route_table.public[0]
}
moved {
  from = module.vpc.aws_route_table_association.private[0]
  to   = module.network.module.vpc.aws_route_table_association.private[0]
}
moved {
  from = module.vpc.aws_route_table_association.public[0]
  to   = module.network.module.vpc.aws_route_table_association.public[0]
}
moved {
  from = module.vpc.aws_route_table_association.private[1]
  to   = module.network.module.vpc.aws_route_table_association.private[1]
}
moved {
  from = module.vpc.aws_route_table_association.public[1]
  to   = module.network.module.vpc.aws_route_table_association.public[1]
}
moved {
  from = module.vpc.aws_subnet.public[0]
  to   = module.network.module.vpc.aws_subnet.public[0]
}
moved {
  from = module.vpc.aws_subnet.public[1]
  to   = module.network.module.vpc.aws_subnet.public[1]
}
