locals {
  root_host_name = "homeunite.us"
  app_name       = "homeuniteus"
  listener_arn   = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3"
  vpc_id         = "vpc-0bec93a4d80243845"
  path_pattens   = ["/*"]
  subdomains = [
    "dev",
    "qa",
    "incubator"
  ]
  host_names = [for subdomain in local.subdomains : "${subdomain}.${local.app_name}"]
  lb_arn     = "arn:aws:elasticloadbalancing:us-west-2:035866691871:loadbalancer/app/incubator-prod-lb/7451adf77133ef36"
}
