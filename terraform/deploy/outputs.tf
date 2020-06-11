output "loadbalancer" {
  value = module.concourse_lb
}

output "cognito" {
  value = module.cognito.outputs
}

output "route_tables" {
  value = module.vpc.outputs.route_tables_private
}
