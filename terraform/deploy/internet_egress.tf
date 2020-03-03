resource "aws_security_group_rule" "internet_proxy_endpoint_from_concourse_web" {
  description              = "Accept requests to Internet Proxy endpoint from Concourse Web nodes"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = module.vpc.outputs.internet_egress_sg.id
  source_security_group_id = module.concourse_web.outputs.security_group.id
}

resource "aws_security_group_rule" "internet_proxy_endpoint_from_concourse_worker" {
  description              = "Accept requests to Internet Proxy endpoint from Concourse Worker nodes"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = module.vpc.outputs.internet_egress_sg.id
  source_security_group_id = module.concourse_worker.outputs.security_group.id
}

resource "aws_security_group_rule" "concourse_web_to_internet_proxy_endpoint" {
  description              = "Allow Concourse Web nodes to reach Internet Proxy endpoint"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = module.concourse_web.outputs.security_group.id
  source_security_group_id = module.vpc.outputs.internet_egress_sg.id
}

resource "aws_security_group_rule" "concourse_worker_to_internet_proxy_endpoint" {
  description              = "Allow Concourse Worker nodes to reach Internet Proxy endpoint"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  security_group_id        = module.concourse_worker.outputs.security_group.id
  source_security_group_id = module.vpc.outputs.internet_egress_sg.id
}
