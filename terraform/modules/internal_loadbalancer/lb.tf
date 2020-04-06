resource "aws_lb" "internal_lb" {
  name               = var.name
  internal           = true
  load_balancer_type = "application"
  subnets            = var.vpc.aws_subnets_private[*].id
  security_groups    = [aws_security_group.internal_lb.id]
  tags               = merge(var.tags, { Name = "${var.name}-int-lb" })
}

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = aws_lb.internal_lb.arn
  port              = 2222
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = var.concourse_web.ssh_target_group_arn
  }
}
