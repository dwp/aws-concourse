module "concourse_lb" {
  source = "../modules/loadbalancer"

  name    = "${var.name}-public"
  lb_name = var.name
  tags    = local.tags

  concourse_web          = module.concourse_web.outputs
  parent_domain_name     = local.parent_domain_name[local.environment]
  vpc                    = module.vpc.outputs
  wafregional_web_acl_id = module.waf.wafregional_web_acl_id
  whitelist_cidr_blocks  = local.whitelist_cidr_blocks
  logging_bucket         = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
}

locals {
  amazon_region_domain = "${data.aws_region.current.name}.amazonaws.com"
}

module "concourse_web" {
  source = "../modules/concourse_web"

  name = var.name

  tags = merge(
    local.tags,
    {
      Name = "concourse-web"
    }
  )

  ami_id                = local.ami_id
  concourse_web_config  = var.concourse_web_config
  database              = module.database.outputs
  internal_loadbalancer = module.concourse_internal_lb.outputs
  loadbalancer          = module.concourse_lb.outputs
  log_group             = module.concourse_web_log_group.outputs
  vpc                   = module.vpc.outputs
  ssm_name_prefix       = var.name
  github_cidr_block     = var.github_vpc.cidr_block
  s3_prefix_list_id     = module.vpc.outputs.s3_prefix_list_id
  cognito_client_secret = data.terraform_remote_state.dataworks_cognito.outputs.cognito.app_client.client_secret #module.cognito.outputs.app_client.client_secret
  cognito_client_id     = data.terraform_remote_state.dataworks_cognito.outputs.cognito.app_client.id            # module.cognito.outputs.app_client.id
  cognito_domain        = data.terraform_remote_state.dataworks_cognito.outputs.cognito.user_pool_domain         #module.cognito.outputs.user_pool_domain
  cognito_issuer        = data.terraform_remote_state.dataworks_cognito.outputs.cognito.issuer                   #module.cognito.outputs.issuer
  cognito_name          = data.terraform_remote_state.dataworks_cognito.outputs.cognito.name                     #module.cognito.outputs.name
  proxy = {
    http_proxy  = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    https_proxy = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    no_proxy    = local.no_proxy
  }
  enterprise_github_certs = local.enterprise_github_certs

  proxy_host                 = module.vpc.outputs.internet_proxy_endpoint
  install_tenable            = local.tenable_install[local.environment]
  install_trend              = local.trend_install[local.environment]
  install_tanium             = local.tanium_install[local.environment]
  tanium_server_1            = module.vpc.outputs.tanium_service_endpoint
  tanium_server_2            = local.tanium2
  tanium_service_endpoint_id = module.vpc.outputs.tanium_service_endpoint_id
  tanium_env                 = local.tanium_env[local.environment]
  tanium_log_level           = local.tanium_log_level[local.environment]
  tenant                     = local.tenant
  tenantid                   = local.tenantid
  token                      = local.token
  policyid                   = local.policy_id[local.environment]
  tanium_prefix              = local.tanium_prefix[local.environment]
  config_bucket_id           = data.terraform_remote_state.management.outputs.config_bucket.id
  config_bucket_arn          = data.terraform_remote_state.management.outputs.config_bucket.arn
  config_bucket_cmk_arn      = data.terraform_remote_state.management.outputs.config_bucket_cmk.arn
  s3_scripts_bucket          = data.terraform_remote_state.management.outputs.config_bucket.id

  web = {
    instance_type         = "t3.xlarge"
    max_instance_lifetime = 60 * 60 * 24 * 7
    count                 = 1
    environment_override  = {}
  }
}

module "concourse_web_log_group" {
  source = "../modules/cloudwatch_log_group"

  name = var.name
  tags = local.tags

  group_name        = "concourse-web"
  retention_in_days = 30
}

module "concourse_internal_lb" {
  source = "../modules/internal_loadbalancer"

  name    = "${var.name}-private"
  lb_name = var.name
  tags    = local.tags

  concourse_web                         = module.concourse_web.outputs
  concourse_worker                      = module.concourse_worker.outputs
  parent_domain_name                    = local.parent_domain_name[local.environment]
  vpc                                   = module.vpc.outputs
  whitelist_cidr_blocks                 = var.whitelist_cidr_blocks
  concourse_internal_allowed_principals = formatlist("arn:aws:iam::%s:root", [data.aws_caller_identity.current.account_id, var.github_vpc.owner])
  logging_bucket                        = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id

}

module "concourse_worker" {
  source = "../modules/concourse_worker"

  name = var.name

  tags = merge(
    local.tags,
    {
      Name = "concourse-worker"
    }
  )

  ami_id                  = local.ami_id
  concourse_worker_config = var.concourse_worker_config
  internal_loadbalancer   = module.concourse_internal_lb.outputs
  loadbalancer            = module.concourse_lb.outputs
  log_group               = module.concourse_worker_log_group.outputs
  vpc                     = module.vpc.outputs
  ssm_name_prefix         = var.name
  github_cidr_block       = var.github_vpc.cidr_block
  s3_prefix_list_id       = module.vpc.outputs.s3_prefix_list_id
  dynamodb_prefix_list_id = module.vpc.outputs.dynamodb_prefix_list_id
  concourse_web           = module.concourse_web.outputs
  concourse_worker_role   = "concourse-worker"
  proxy = {
    http_proxy  = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    https_proxy = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    no_proxy    = local.no_proxy
  }
  enterprise_github_certs = local.enterprise_github_certs

  proxy_host                 = module.vpc.outputs.internet_proxy_endpoint
  install_tenable            = local.tenable_install[local.environment]
  install_trend              = local.trend_install[local.environment]
  install_tanium             = local.tanium_install[local.environment]
  tanium_server_1            = module.vpc.outputs.tanium_service_endpoint
  tanium_server_2            = local.tanium2
  tanium_service_endpoint_id = module.vpc.outputs.tanium_service_endpoint_id
  tanium_env                 = local.tanium_env[local.environment]
  tanium_log_level           = local.tanium_log_level[local.environment]
  tenant                     = local.tenant
  tenantid                   = local.tenantid
  token                      = local.token
  policyid                   = local.policy_id[local.environment]
  tanium_prefix              = local.tanium_prefix[local.environment]
  config_bucket_id           = data.terraform_remote_state.management.outputs.config_bucket.id
  config_bucket_arn          = data.terraform_remote_state.management.outputs.config_bucket.arn
  config_bucket_cmk_arn      = data.terraform_remote_state.management.outputs.config_bucket_cmk.arn
  s3_scripts_bucket          = data.terraform_remote_state.management.outputs.config_bucket.id

  worker = {
    instance_type        = local.concourse_worker_node_inst_type[local.environment]
    count                = local.concourse_worker_node_inst_count[local.environment]
    environment_override = {}
  }

  asg_night = {
    min_size         = local.concourse_worker_asg_night_inst_count[local.environment]
    max_size         = local.concourse_worker_asg_night_inst_count[local.environment]
    desired_capacity = local.concourse_worker_asg_night_inst_count[local.environment]
    time             = "0 19 * * 1-5"
  }

  asg_day = {
    min_size         = local.concourse_worker_asg_day_inst_count[local.environment]
    max_size         = local.concourse_worker_asg_day_inst_count[local.environment]
    desired_capacity = local.concourse_worker_asg_day_inst_count[local.environment]
    time             = "0 7 * * 1-5"
  }

}

module "concourse_worker_log_group" {
  source = "../modules/cloudwatch_log_group"

  name = var.name
  tags = local.tags

  group_name        = "concourse-worker"
  retention_in_days = 30
}

module "database" {
  source = "../modules/database"

  name = var.name
  tags = local.tags

  vpc = module.vpc.outputs

  database = {
    instance_type           = "db.t3.medium"
    db_count                = length(data.aws_availability_zones.available.zone_ids)
    engine                  = "aurora-postgresql"
    engine_version          = "10.18"
    backup_retention_period = 14
    preferred_backup_window = "01:00-03:00"
  }

  database_credentials = {
    username = var.concourse_web_config.database_username
    password = var.concourse_web_config.database_password
  }
}

module "vpc" {
  source = "../modules/vpc"

  name                        = var.name
  tags                        = local.tags
  vpc_cidr_block              = local.cidr_block[local.environment].ci-cd-vpc
  whitelist_cidr_blocks       = local.whitelist_cidr_blocks
  internet_proxy_fqdn         = module.vpc.outputs.internet_proxy_endpoint
  internet_proxy_service_name = data.terraform_remote_state.internet_egress.outputs.internet_proxy_service.service_name
  vpc_endpoint_source_sg_ids  = [module.concourse_web.outputs.security_group.id, module.concourse_worker.outputs.security_group.id]
  tanium_service_name         = local.tanium_service_name[local.environment]
}

module "concourse_waf_log_group" {
  source = "../modules/cloudwatch_log_group"

  name = var.name
  tags = local.tags

  group_name        = "waf"
  retention_in_days = 180
}

module "waf" {
  source                = "../modules/waf"
  name                  = var.name
  whitelist_cidr_blocks = var.whitelist_cidr_blocks
  log_bucket            = data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn
  cloudwatch_log_group  = "/${var.name}/waf"
  github_metadata       = local.github_hooks
  tags                  = local.tags
}
