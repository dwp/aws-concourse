module "amis" {
  source = "../modules/amis"

  ami_filter_name   = var.ami_filter_name
  ami_filter_values = var.ami_filter_values
  ami_owners        = var.ami_owners
}

module "concourse_lb" {
  source = "../modules/loadbalancer"

  name    = "${var.name}-public"
  lb_name = var.name
  tags    = local.tags

  concourse_web          = module.concourse_web.outputs
  parent_domain_name     = local.parent_domain_name[local.environment]
  vpc                    = module.vpc.outputs
  wafregional_web_acl_id = module.waf.wafregional_web_acl_id
  whitelist_cidr_blocks  = concat(var.whitelist_cidr_blocks, local.github_metadata.hooks, local.ithc_cidr_blocks)
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

  ami_id                = module.amis.ami_id
  concourse             = var.concourse
  concourse_keys        = var.concourse_keys
  concourse_web_config  = var.concourse_web_config
  database              = module.database.outputs
  internal_loadbalancer = module.concourse_internal_lb.outputs
  loadbalancer          = module.concourse_lb.outputs
  log_group             = module.concourse_web_log_group.outputs
  vpc                   = module.vpc.outputs
  ssm_name_prefix       = var.name
  github_cidr_block     = var.github_vpc.cidr_block
  s3_prefix_list_id     = module.vpc.outputs.s3_prefix_list_id
  cognito_client_secret = module.cognito.outputs.app_client.client_secret
  cognito_client_id     = module.cognito.outputs.app_client.id
  cognito_domain        = module.cognito.outputs.user_pool_domain
  cognito_issuer        = module.cognito.outputs.issuer
  cognito_name          = module.cognito.outputs.name
  proxy = {
    http_proxy  = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    https_proxy = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    no_proxy    = local.no_proxy
  }
  enterprise_github_certs = local.enterprise_github_certs
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

  ami_id                  = module.amis.ami_id
  concourse               = var.concourse
  concourse_keys          = var.concourse_keys
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

  worker = {
    instance_type        = "c4.2xlarge"
    count                = 3
    environment_override = {}
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
    engine_version          = "10.7"
    backup_retention_period = 14
    preferred_backup_window = "01:00-03:00"
  }
}

module "vpc" {
  source = "../modules/vpc"

  name                        = var.name
  tags                        = local.tags
  vpc_cidr_block              = local.cidr_block[local.environment].ci-cd-vpc
  whitelist_cidr_blocks       = concat(var.whitelist_cidr_blocks, local.github_metadata.hooks)
  internet_proxy_fqdn         = data.terraform_remote_state.internet_egress.outputs.internet_proxy_service.dns_name
  internet_proxy_service_name = data.terraform_remote_state.internet_egress.outputs.internet_proxy_service.service_name
  vpc_endpoint_source_sg_ids  = [module.concourse_web.outputs.security_group.id, module.concourse_worker.outputs.security_group.id]
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
  github_metadata       = local.github_metadata
  tags                  = local.tags
}

module "cognito" {
  source = "../modules/cognito"

  clients = [
    "dataworks",
  ]

  root_dns_names = values(local.root_dns_name)
  domain         = local.cognito_domain
  loadbalancer   = module.concourse_lb.outputs
}
