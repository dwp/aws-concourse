resource "aws_security_group" "web" {
  vpc_id = var.vpc.aws_vpc.id
  tags   = merge(var.tags, { Name = local.name })

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
  description              = "inbound traffic to web nodes from worker nodes via lb"
  from_port                = 2222
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  to_port                  = 2222
  type                     = "ingress"
  source_security_group_id = var.loadbalancer.security_group_id
}

resource "aws_security_group_rule" "web_db_out" {
   description              = "web_db_out"
   description              = "outbound connectivity from web nodes to db"
   from_port                = 5432
   protocol                 = "tcp"
   security_group_id        = var.database.security_group_id
   to_port                  = 5432
   type                     = "egress"
   source_security_group_id = aws_security_group.web.id
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

