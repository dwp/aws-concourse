locals {
  name = "${var.name}-concourse-web"

  environment = terraform.workspace == "default" ? "management-dev" : terraform.workspace

  hcs_environment = {
    development    = "Dev"
    qa             = "Test"
    integration    = "Stage"
    preprod        = "Stage"
    production     = "Production"
    management     = "SP_Tooling"
    management-dev = "DT_Tooling"
  }
  ebs_volume_size_web = {
    management-dev = 334
    management     = 667
  }

  ebs_volume_type_web = {
    management-dev = "gp3"
    management     = "gp3"
  }
}
