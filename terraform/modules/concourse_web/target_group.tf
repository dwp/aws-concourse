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
    enabled = false
    type    = "source_ip"
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

  # TODO healthcheck issues
  # using port 2222 creates hundreds of lines of log spam a minute of failed SSH connections into CloudWatch
  # using port 8080 requires a security group rule to allow all traffic from the private subnets ip ranges, as we cannot
  # get the addresses of the NLB, from where the healthchecks originate, which is too broad to be accepted
  health_check {
    port     = "8080"
    protocol = "TCP"
  }

  # https://github.com/terraform-providers/terraform-provider-aws/issues/9093
  stickiness {
    enabled = false
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = local.name })
}

resource "aws_autoscaling_attachment" "web_ssh" {
  alb_target_group_arn   = aws_lb_target_group.web_ssh.id
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_lb_target_group" "int_web_http" {
  name     = "internal-${local.name}-http"
  port     = 8080
  protocol = "TCP"
  vpc_id   = var.vpc.aws_vpc.id

  stickiness {
    enabled = false
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = local.name })
}

resource "aws_autoscaling_attachment" "int_web_http" {
  alb_target_group_arn   = aws_lb_target_group.int_web_http.id
  autoscaling_group_name = aws_autoscaling_group.web.name
}
