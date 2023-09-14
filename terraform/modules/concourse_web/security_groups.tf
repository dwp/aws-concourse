resource "aws_security_group" "web" {
  name        = local.name
  description = "Concourse Web Nodes"
  vpc_id      = var.vpc.aws_vpc.id
  tags        = merge(var.tags, { Name = local.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "web_lb_in_http" {
  description              = "inbound traffic to web nodes from lb"
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  to_port                  = 8080
  type                     = "ingress"
  source_security_group_id = var.loadbalancer.security_group_id
}

resource "aws_security_group_rule" "lb_web_out_http" {
  description              = "outbound traffic from web nodes to lb"
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = var.loadbalancer.security_group_id
  to_port                  = 8080
  type                     = "egress"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "int_lb_web_in_http" {
  description       = "inbound traffic to web nodes from internal lb"
  from_port         = 8080
  protocol          = "tcp"
  cidr_blocks       = var.vpc.aws_subnets_private.*.cidr_block
  to_port           = 8080
  type              = "ingress"
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_internal_in_tcp" {
  description              = "allow web nodes to communicate with each other"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  to_port                  = 65535
  type                     = "ingress"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_internal_out_tcp" {
  description              = "web_internal_out_tcp"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  to_port                  = 65535
  type                     = "egress"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_lb_in_ssh" {
  description       = "inbound traffic to web nodes from worker nodes via lb"
  from_port         = 2222
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  to_port           = 2222
  type              = "ingress"
  cidr_blocks       = var.vpc.aws_subnets_private.*.cidr_block
}

resource "aws_security_group_rule" "web_db_out" {
  description              = "outbound connectivity from web nodes to db"
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  to_port                  = 5432
  type                     = "egress"
  source_security_group_id = var.database.security_group_id
}

resource "aws_security_group_rule" "db_web_in" {
  description              = "inbound connectivity to db from web nodes"
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = var.database.security_group_id
  to_port                  = 5432
  type                     = "ingress"
  source_security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_ucfs_github_inbound_https" {
  description       = "web inbound https connectivity"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = [var.github_cidr_block]
}

resource "aws_security_group_rule" "web_outbound_s3_https" {
  security_group_id = aws_security_group.web.id
  description       = "s3 outbound https connectivity"
  type              = "egress"
  prefix_list_ids   = [var.s3_prefix_list_id]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_security_group_rule" "web_outbound_s3_http" {
  security_group_id = aws_security_group.web.id
  description       = "s3 outbound http connectivity (for YUM updates)"
  type              = "egress"
  prefix_list_ids   = [var.s3_prefix_list_id]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_security_group_rule" "web_lb_in_metrics" {
  description       = "inbound traffic to web nodes metrics port"
  from_port         = 9090
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  to_port           = 9090
  type              = "ingress"
  # CHANGE BELOW TO PROMETHEUS LOCATION/SUBNET
  cidr_blocks = var.vpc.aws_subnets_private.*.cidr_block
}

resource "aws_security_group_rule" "worker_ucfs_github_outbound_https" {
  description       = "web outbound enterprise github connectivity for auth"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = [var.github_cidr_block]
}

resource "aws_security_group_rule" "concourse_web_outbound_tanium_1" {
  description              = "Concourse web outbound port 1 to Tanium"
  type                     = "egress"
  from_port                = var.tanium_port_1
  to_port                  = var.tanium_port_1
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = var.tanium_service_endpoint_id
}

resource "aws_security_group_rule" "concourse_web_outbound_tanium_2" {
  description              = "Concourse web outbound port 2 to Tanium"
  type                     = "egress"
  from_port                = var.tanium_port_2
  to_port                  = var.tanium_port_2
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = var.tanium_service_endpoint_id
}

resource "aws_security_group_rule" "concourse_web_inbound_tanium_1" {
  description              = "Concourse web inbound port 1 from Tanium"
  type                     = "ingress"
  from_port                = var.tanium_port_1
  to_port                  = var.tanium_port_1
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = var.tanium_service_endpoint_id
}

resource "aws_security_group_rule" "concourse_web_inbound_tanium_2" {
  description              = "Concourse web inbound port 2 from Tanium"
  type                     = "ingress"
  from_port                = var.tanium_port_2
  to_port                  = var.tanium_port_2
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = var.tanium_service_endpoint_id
}
