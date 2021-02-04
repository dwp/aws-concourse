locals {
  name = "${var.name}-concourse-web"

  environment = terraform.workspace == "default" ? "management-dev" : terraform.workspace

  ebs_volume_size_web = {
    management-dev = 334
    management     = 667
  }

  ebs_volume_type_web = {
    management-dev = "gp3"
    management     = "gp3"
  }
}
