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

  name    = "${var.name}-public"
  lb_name = var.name
  tags    = local.tags

  concourse_web          = module.concourse_web.outputs
  parent_domain_name     = local.parent_domain_name[local.environment]
  vpc                    = module.vpc.outputs
  wafregional_web_acl_id = module.waf.wafregional_web_acl_id
  whitelist_cidr_blocks  = var.whitelist_cidr_blocks
}

locals {
  amazon_region_domain = "${data.aws_region.current.name}.amazonaws.com"
  endpoint_services    = ["secretsmanager", "ec2messages", "s3", "monitoring", "ssm", "ssmmessages", "ec2", "kms", "logs"]
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
  concourse_keys        = module.concourse_keys.outputs
  concourse_secrets     = module.concourse_secrets.outputs
  database              = module.database.outputs
  database_secrets      = module.database_secrets.outputs
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
  remote_state          = local.remote_state
  proxy = {
    http_proxy  = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    https_proxy = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    no_proxy    = "169.254.169.254,${join(",", formatlist("%s.%s", local.endpoint_services, local.amazon_region_domain))}"
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

  ami_id                = module.amis.ami_id
  concourse             = var.concourse
  concourse_keys        = module.concourse_keys.outputs
  internal_loadbalancer = module.concourse_internal_lb.outputs
  loadbalancer          = module.concourse_lb.outputs
  log_group             = module.concourse_worker_log_group.outputs
  vpc                   = module.vpc.outputs
  ssm_name_prefix       = var.name
  github_cidr_block     = var.github_vpc.cidr_block
  s3_prefix_list_id     = module.vpc.outputs.s3_prefix_list_id
  remote_state          = local.remote_state
  concourse_web         = module.concourse_web.outputs
  proxy = {
    http_proxy  = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    https_proxy = "http://${module.vpc.outputs.internet_proxy_endpoint}:3128"
    no_proxy    = "169.254.169.254,${join(",", formatlist("%s.%s", local.endpoint_services, local.amazon_region_domain))}"
  }
  worker = {
    instance_type        = "m4.large"
    count                = 1
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
  vpc_endpoint_source_sg_ids  = [module.concourse_web.outputs.security_group.id, module.concourse_worker.outputs.security_group.id]
}

module "waf" {
  source = "../modules/waf"

  name = var.name

  whitelist_cidr_blocks = var.whitelist_cidr_blocks
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
