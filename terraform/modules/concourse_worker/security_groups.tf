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

resource "aws_security_group_rule" "worker_lb_out_http" {
  description       = "outbound http traffic to web nodes from worker nodes via lb"
  from_port         = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.worker.id
  to_port           = 8080
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

resource "aws_security_group_rule" "worker_packer_cli_ssh" {
  description       = "Allow Packer CLI to send SSH traffic"
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ec2_packer_ssh" {
  description       = "Allow EC2 instances to receive SSH traffic"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "concourse_worker_outbound_tanium_1" {
  description              = "Concourse worker outbound port 1 to Tanium"
  type                     = "egress"
  from_port                = var.tanium_port_1
  to_port                  = var.tanium_port_1
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.tanium_service_endpoint.id
}

resource "aws_security_group_rule" "concourse_worker_outbound_tanium_2" {
  description              = "Concourse worker outbound port 2 to Tanium"
  type                     = "egress"
  from_port                = var.tanium_port_2
  to_port                  = var.tanium_port_2
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.tanium_service_endpoint.id
}

resource "aws_security_group_rule" "concourse_worker_inbound_tanium_1" {
  description              = "Concourse worker inbound port 1 from Tanium"
  type                     = "ingress"
  from_port                = var.tanium_port_1
  to_port                  = var.tanium_port_1
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.tanium_service_endpoint.id
}

resource "aws_security_group_rule" "concourse_worker_inbound_tanium_2" {
  description              = "Concourse worker inbound port 2 from Tanium"
  type                     = "ingress"
  from_port                = var.tanium_port_2
  to_port                  = var.tanium_port_2
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.tanium_service_endpoint.id

}
