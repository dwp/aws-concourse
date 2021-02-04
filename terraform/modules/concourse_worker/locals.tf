locals {
  name         = "${var.name}-concourse-worker"

  environment = terraform.workspace == "default" ? "management-dev" : terraform.workspace

  service_port = 2222

  ebs_volume_size_worker = {
    management-dev = 334
    management     = 667
  }

  ebs_volume_type_worker = {
    management-dev = "gp3"
    management     = "gp3"
  }
}
