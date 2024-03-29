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
    management     = "r5a.2xlarge"
  }

  concourse_worker_node_inst_count = {
    management-dev = 2
    management     = 3
  }

  concourse_worker_asg_night_inst_count = {
    management-dev = 0
    management     = 3
  }

  concourse_worker_asg_day_inst_count = {
    management-dev = 2
    management     = 3
  }

  kali_users = jsondecode(data.aws_secretsmanager_secret_version.internet_ingress.secret_binary)["ssh_bastion_users"]

  tenable_install = {
    development    = "true"
    qa             = "true"
    integration    = "true"
    preprod        = "true"
    production     = "true"
    management-dev = "true"
    management     = "true"
  }

  trend_install = {
    development    = "true"
    qa             = "true"
    integration    = "true"
    preprod        = "true"
    production     = "true"
    management-dev = "true"
    management     = "true"
  }

  tanium_install = {
    development    = "true"
    qa             = "true"
    integration    = "true"
    preprod        = "true"
    production     = "true"
    management-dev = "true"
    management     = "true"
  }


  ## Tanium config
  ## Tanium Servers
  tanium1 = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium[local.environment].server_1
  tanium2 = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium[local.environment].server_2

  tanium_service_name = {
    development    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_name.non_prod
    qa             = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_name.prod
    integration    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_name.prod
    preprod        = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_name.prod
    production     = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_name.prod
    management-dev = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_name.non_prod
    management     = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_name.prod
  }

  tanium_service_id = {
    development    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_id.non_prod
    qa             = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_id.prod
    integration    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_id.prod
    preprod        = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_id.prod
    production     = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_id.prod
    management-dev = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_id.non_prod
    management     = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium.service_id.prod
  }
  ## Tanium Env Config
  tanium_env = {
    development    = "pre-prod"
    qa             = "prod"
    integration    = "prod"
    preprod        = "prod"
    production     = "prod"
    management-dev = "pre-prod"
    management     = "prod"
  }

  ## Tanium prefix list for TGW for Security Group rules
  tanium_prefix = {
    development    = [data.aws_ec2_managed_prefix_list.list.id]
    qa             = [data.aws_ec2_managed_prefix_list.list.id]
    integration    = [data.aws_ec2_managed_prefix_list.list.id]
    preprod        = [data.aws_ec2_managed_prefix_list.list.id]
    production     = [data.aws_ec2_managed_prefix_list.list.id]
    management-dev = [data.aws_ec2_managed_prefix_list.list.id]
    management     = [data.aws_ec2_managed_prefix_list.list.id]
  }

  tanium_log_level = {
    development    = "41"
    qa             = "41"
    integration    = "41"
    preprod        = "41"
    production     = "41"
    management-dev = "41"
    management     = "41"
  }

  ## Trend config
  tenant   = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.tenant
  tenantid = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.tenantid
  token    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.token

  policy_id = {
    development    = "1651"
    qa             = "1651"
    integration    = "1651"
    preprod        = "1717"
    production     = "1717"
    management-dev = "1651"
    management     = "1717"
  }

}
