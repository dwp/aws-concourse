resource "aws_lb" "lb" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.vpc.aws_subnets_public[*].id
  security_groups    = [aws_security_group.lb.id]
  tags               = merge(var.tags, { Name = "${var.name}-lb" })

  access_logs {
    bucket  = var.logging_bucket
    prefix  = "ELBLogs/${var.name}"
    enabled = true
  }
}

resource "aws_wafregional_web_acl_association" "lb" {
  resource_arn = aws_lb.lb.arn
  web_acl_id   = var.wafregional_web_acl_id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.concourse.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "FORBIDDEN"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "https" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = var.concourse_web.http_target_group_arn
  }

  condition {
    host_header {
      values = [local.fqdn]
    }
  }
}
