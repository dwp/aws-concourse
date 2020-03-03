module "amis" {
  source = "../modules/amis"

  ami_filter_name   = var.ami_filter_name
  ami_filter_values = var.ami_filter_values
  ami_owners        = var.ami_owners
}

module "concourse_keys" {
  source = "../modules/concourse_keys"

  ssm_name_prefix = var.name
}

module "concourse_lb" {
  source = "../modules/loadbalancer"

  name = var.name
  tags = local.tags

  concourse_web          = module.concourse_web.outputs
  parent_domain_name     = local.parent_domain_name[local.environment]
  vpc                    = module.vpc.outputs
  wafregional_web_acl_id = module.waf.wafregional_web_acl_id
  whitelist_cidr_blocks  = var.whitelist_cidr_blocks
}

module "concourse_web" {
  source = "../modules/concourse_web"

  name = var.name
  tags = local.tags

  ami_id                = module.amis.ami_id
  cognito               = var.cognito
  concourse             = var.concourse
  concourse_keys        = module.concourse_keys.outputs
  concourse_secrets     = module.concourse_secrets.outputs
  database              = module.database.outputs
  database_secrets      = module.database_secrets.outputs
  internal_loadbalancer = module.concourse_internal_lb.outputs
  loadbalancer          = module.concourse_lb.outputs
  log_group             = module.concourse_web_log_group.outputs
  vpc                   = module.vpc.outputs
  ssm_name_prefix       = var.name
  proxy = {
    http_proxy  = data.terraform_remote_state.internet_egress.outputs.internet_proxy.http_address
    https_proxy = data.terraform_remote_state.internet_egress.outputs.internet_proxy.https_address
    no_proxy    = var.concourse_no_proxy
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

  name = var.name
  tags = local.tags

  concourse_web         = module.concourse_web.outputs
  parent_domain_name    = local.parent_domain_name[local.environment]
  vpc                   = module.vpc.outputs
  whitelist_cidr_blocks = var.whitelist_cidr_blocks
}

module "concourse_worker" {
  source = "../modules/concourse_worker"

  name = var.name
  tags = local.tags

  ami_id          = module.amis.ami_id
  concourse       = var.concourse
  concourse_keys  = module.concourse_keys.outputs
  loadbalancer    = module.concourse_internal_lb.outputs
  log_group       = module.concourse_worker_log_group.outputs
  vpc             = module.vpc.outputs
  ssm_name_prefix = var.name
}

module "concourse_worker_log_group" {
  source = "../modules/cloudwatch_log_group"

  name = var.name
  tags = local.tags

  group_name        = "concourse-worker"
  retention_in_days = 30
}

module "concourse_secrets" {
  source = "../modules/user_password"

  ssm_name_prefix = var.name
}

module "database" {
  source = "../modules/database"

  name = var.name
  tags = local.tags

  secrets = module.database_secrets.outputs
  vpc     = module.vpc.outputs
}

module "database_secrets" {
  source = "../modules/user_password"

  ssm_name_prefix = var.name
}

module "vpc" {
  source = "../modules/vpc"

  name                        = var.name
  tags                        = local.tags
  vpc_cidr_block              = local.cidr_block[local.environment].ci-cd-vpc
  whitelist_cidr_blocks       = var.whitelist_cidr_blocks
  internet_proxy_fqdn         = data.terraform_remote_state.internet_egress.outputs.internet_proxy_service.dns_name
  internet_proxy_service_name = data.terraform_remote_state.internet_egress.outputs.internet_proxy_service.service_name
}

module "waf" {
  source = "../modules/waf"

  name = var.name

  whitelist_cidr_blocks = var.whitelist_cidr_blocks
}
