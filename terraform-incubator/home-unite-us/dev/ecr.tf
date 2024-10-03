
resource "aws_ecr_repository" "this" {
  image_tag_mutability = "MUTABLE"
  name                 = local.app_name
  tags = {
    "Organization" = "Hack for LA"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_lb_listener" "listener" {
  arn = local.listener_arn
}

