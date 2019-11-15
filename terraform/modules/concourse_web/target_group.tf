resource "aws_lb_target_group" "web_http" {
  name     = "${local.name}-http"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc.aws_vpc.id

  health_check {
    port    = "8080"
    path    = "/"
    matcher = "200"
  }

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  tags = merge(var.tags, { Name = local.name })
}

resource "aws_autoscaling_attachment" "web_http" {
  alb_target_group_arn   = aws_lb_target_group.web_http.id
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_lb_target_group" "web_ssh" {
  name     = "${local.name}-ssh"
  port     = 2222
  protocol = "TCP"
  vpc_id   = var.vpc.aws_vpc.id

  health_check {
    port     = "8080"
    protocol = "TCP"
  }

  # https://github.com/terraform-providers/terraform-provider-aws/issues/9093
  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags = merge(var.tags, { Name = local.name })
}

resource "aws_autoscaling_attachment" "web_ssh" {
  alb_target_group_arn   = aws_lb_target_group.web_ssh.id
  autoscaling_group_name = aws_autoscaling_group.web.name
}
