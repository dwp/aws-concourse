output "loadbalancer" {
  value = module.concourse_lb
}

output "cognito" {
  value = module.cognito.outputs
}
