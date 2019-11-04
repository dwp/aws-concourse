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

  tags = merge(var.tags, { Name = local.name })
}

resource "aws_lb_target_group_attachment" "web_http" {
  count = var.web.count

  target_group_arn = aws_lb_target_group.web_http.id
  target_id        = aws_instance.web[count.index].id
}

resource "aws_lb_target_group" "web_ssh" {
  name     = "${local.name}-ssh"
  port     = 2222
  protocol = "TCP"
  vpc_id   = var.vpc.aws_vpc.id

  # https://github.com/terraform-providers/terraform-provider-aws/issues/9093
  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags = merge(var.tags, { Name = local.name })
}

resource "aws_lb_target_group_attachment" "web_ssh" {
  count = var.web.count

  target_group_arn = aws_lb_target_group.web_ssh.id
  target_id        = aws_instance.web[count.index].id
}
