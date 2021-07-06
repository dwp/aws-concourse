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

  kali_users = jsondecode(data.aws_secretsmanager_secret_version.internet_ingress.secret_binary)["ssh_bastion_users"]

  concourse_url = terraform.workspace == "default" ? "https://ci.wip.${var.parent_domain_name}" : "https://ci.${var.parent_domain_name}"
}
