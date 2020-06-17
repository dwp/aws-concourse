resource "aws_security_group" "worker" {
  name        = local.name
  description = "Concourse Worker Nodes"
  vpc_id      = var.vpc.aws_vpc.id
  tags        = merge(var.tags, { Name = local.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "worker_ucfs_github_outbound_https" {
  description       = "worker outbound https connectivity"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.worker.id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = [var.github_cidr_block]
}

resource "aws_security_group_rule" "worker_lb_out_ssh" {
  description       = "outbound traffic to web nodes from worker nodes via lb"
  from_port         = 2222
  protocol          = "tcp"
  security_group_id = aws_security_group.worker.id
  to_port           = 2222
  type              = "egress"
  cidr_blocks       = var.vpc.aws_subnets_private.*.cidr_block
}

resource "aws_security_group_rule" "worker_outbound_s3_https" {
  security_group_id = aws_security_group.worker.id
  description       = "s3 outbound https connectivity"
  type              = "egress"
  prefix_list_ids   = [var.s3_prefix_list_id]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_security_group_rule" "worker_outbound_s3_http" {
  security_group_id = aws_security_group.worker.id
  description       = "s3 outbound http connectivity (for YUM updates)"
  type              = "egress"
  prefix_list_ids   = [var.s3_prefix_list_id]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_security_group_rule" "web_outbound_dynamodb_https" {
  security_group_id = aws_security_group.worker.id
  description       = "dynamodb outbound https connectivity"
  type              = "egress"
  prefix_list_ids   = [var.dynamodb_prefix_list_id]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_security_group_rule" "web_outbound_dynamodb_http" {
  security_group_id = aws_security_group.worker.id
  description       = "dynamodb outbound http connectivity (for YUM updates)"
  type              = "egress"
  prefix_list_ids   = [var.dynamodb_prefix_list_id]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
}
