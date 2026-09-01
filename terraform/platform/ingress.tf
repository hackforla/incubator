# Fronts every project. Its target groups and listener rules are already managed by
# modules/container; this adopts what was missing underneath them.
resource "aws_lb" "this" {
  name               = "incubator-prod-lb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [aws_security_group.alb.id]
  subnets         = [for s in aws_subnet.public : s.id]

  # Written out even where they match provider defaults today: a new default on an old
  # resource shows up as drift, and stating the live value makes that impossible.
  idle_timeout                                = 60
  enable_deletion_protection                  = false
  enable_http2                                = true
  desync_mitigation_mode                      = "defensive"
  drop_invalid_header_fields                  = false
  preserve_host_header                        = false
  xff_header_processing_mode                  = "append"
  enable_xff_client_port                      = false
  enable_tls_version_and_cipher_suite_headers = false
  enable_waf_fail_open                        = false
  enable_zonal_shift                          = false
  client_keep_alive                           = 3600

  tags = {
    Name = "incubator" # live value, not the load balancer's own name

    # Terragrunt-era, from a state file that no longer exists. Adopted, not believed.
    terraform_managed = "true"
    last_changed      = "Thu 2023-Sep-28 06:13:14"
  }

  # Every project's DNS points here; a replacement would mint a new name and break all of it.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  # The listener's default certificate, `*.vrms.io`. Managed as module.vrms.module.certificate
  # but written literally, since a module cannot read a sibling's output. Rewiring is follow-up.
  certificate_arn = "arn:aws:acm:us-west-2:035866691871:certificate/5f0bd3ee-a6d3-4836-ac82-060756603785"

  # Unmatched traffic goes to the Hack for LA site rather than erroring, which is why an
  # unserved hostname in one of our zones redirects there instead of failing.
  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      host        = "www.hackforla.org"
      path        = "/"
      query       = ""
      status_code = "HTTP_301"
    }
  }
}

# Redirects to HTTPS preserving host, path and query. No rules beyond this default.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}
