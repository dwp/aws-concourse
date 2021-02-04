locals {

  management_workspace = {
    management-dev = "default"
    management     = "management"
  }

  common_tags = {

    CreatedBy = "terraform"

    Owner = "dataworks platform"

    Name         = local.name
    Environment  = local.environment
    Application  = local.name
    Persistence  = "True"
    AutoShutdown = "False"
    Costcode     = var.costcode
    Team         = "DataWorks"
  }

  env_prefix = {
    management-dev = "mgt-dev."
    management     = "mgt."
  }

  deploy_ithc_infra = {
    management-dev = false
    management     = false
  }

  ebs_volume_size = {
    management-dev = 334
    management     = 667
  }

  ebs_volume_type = {
    management-dev = "gp3"
    management     = "gp3"
  }

  kali_users = jsondecode(data.aws_secretsmanager_secret_version.internet_ingress.secret_binary)["ssh_bastion_users"]
}
