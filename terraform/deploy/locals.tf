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

  concourse_worker_node_inst_type = {
    management-dev = "m5a.4xlarge"
    management     = "c4.8xlarge"
  }

  concourse_worker_node_inst_count = {
  management-dev = 3
  management     = 3
  }

  concourse_worker_asg_night_inst_count = {
  management-dev = 0
  management     = 3
  }

  concourse_worker_asg_day_inst_count = {
  management-dev = 3
  management     = 3
  }

  kali_users = jsondecode(data.aws_secretsmanager_secret_version.internet_ingress.secret_binary)["ssh_bastion_users"]
}
