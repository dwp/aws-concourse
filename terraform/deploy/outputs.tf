output "loadbalancer" {
  value = module.concourse_lb
}

output "cognito" {
  value = module.cognito.outputs
}

output "route_tables" {
  value = module.vpc.outputs.route_tables_private
}

output "concourse_web_sg" {
  value = module.concourse_web.outputs.security_group.id
}

output "aws_vpc" {
  value = module.vpc.outputs.aws_vpc
}

output "subnets_private" {
  value = module.vpc.outputs.aws_subnets_private
}

output "s3_prefix_list_id" {
  value = module.vpc.outputs.s3_prefix_list_id
}

output "interface_vpce_sg_id" {
  value = module.vpc.outputs.interface_vpce_sg_id
}
