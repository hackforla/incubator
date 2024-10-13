locals {
  account_id     = "035866691871"
  root_host_name = "homeunite.us"
  app_name       = "homeuniteus"
  elb_name       = "incubator-prod-lb"
  listener_arn   = "arn:aws:elasticloadbalancing:us-west-2:035866691871:listener/app/incubator-prod-lb/7451adf77133ef36/390a225766a4daf3"
  vpc_id         = "vpc-0bec93a4d80243845"
  path_pattens   = ["/*"]
  subdomains = [
    "www",
    "qa"
  ]
  host_names = [for subdomain in local.subdomains : "${subdomain}.${local.root_host_name}"]
  user_group_names = [
    "guests",
    "hosts",
    "coordinators",
    "administrators"
  ]
}
