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

output "endpoint_services" {
  value = local.endpoint_services
}

output "aws_vpc" {
  value = module.vpc.outputs.aws_vpc
}
