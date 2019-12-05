module "amis" {
  source = "../modules/amis"

  ami_filter_name   = var.ami_filter_name
  ami_filter_values = var.ami_filter_values
}

module "concourse_keys" {
  source = "../modules/concourse_keys"

  ssm_name_prefix = var.name
}

module "concourse_lb" {
  source = "../modules/loadbalancer"

  name = var.name
  tags = var.tags

  concourse_web          = module.concourse_web.outputs
  parent_domain_name     = var.parent_domain_name
  vpc                    = module.vpc.outputs
  wafregional_web_acl_id = module.waf.wafregional_web_acl_id
  whitelist_cidr_blocks  = var.whitelist_cidr_blocks
}

module "concourse_web" {
  source = "../modules/concourse_web"

  name = var.name
  tags = var.tags

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
  ssm_name_prefix = var.name
}

module "concourse_web_log_group" {
  source = "../modules/cloudwatch_log_group"

  name = var.name
  tags = var.tags

  group_name = "concourse-web"
}

module "concourse_internal_lb" {
  source = "../modules/internal_loadbalancer"

  name = var.name
  tags = var.tags

  concourse_web         = module.concourse_web.outputs
  parent_domain_name    = var.parent_domain_name
  vpc                   = module.vpc.outputs
  whitelist_cidr_blocks = var.whitelist_cidr_blocks
}

module "concourse_worker" {
  source = "../modules/concourse_worker"

  name = var.name
  tags = var.tags

  ami_id         = module.amis.ami_id
  concourse      = var.concourse
  concourse_keys = module.concourse_keys.outputs
  loadbalancer   = module.concourse_internal_lb.outputs
  log_group      = module.concourse_worker_log_group.outputs
  vpc            = module.vpc.outputs
  ssm_name_prefix = var.name
}

module "concourse_worker_log_group" {
  source = "../modules/cloudwatch_log_group"

  name = var.name
  tags = var.tags

  group_name = "concourse-worker"
}

module "concourse_secrets" {
  source = "../modules/user_password"

  ssm_name_prefix = var.name
}

module "database" {
  source = "../modules/database"

  name = var.name
  tags = var.tags

  secrets = module.database_secrets.outputs
  vpc     = module.vpc.outputs
}

module "database_secrets" {
  source = "../modules/user_password"

  ssm_name_prefix = var.name
}

module "vpc" {
  source = "../modules/vpc"

  name = var.name
  tags = var.tags

  vpc = var.vpc
}

module "waf" {
  source = "../modules/waf"

  name = var.name

  whitelist_cidr_blocks = var.whitelist_cidr_blocks
}
