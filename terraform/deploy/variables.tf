variable "name" {
  description = "cluster name, used in dns"
  type        = string
  default     = "ci"
}

variable "cognito" {
  description = "cognito secret locations/values required for login"
  type        = map(string)

  default = {
    name                        = "cognito"
    issuer                      = "https://cognito-idp.eu-west-2.amazonaws.com/user_pool_id"
    client_id_ssm_parameter     = "/path/to/ssm_param"
    client_secret_ssm_parameter = "/path/to/ssm_param"
    admin_group                 = "ci_admin"
  }
}

variable "concourse" {
  description = "concourse version to install"
  type        = map(string)

  default = {
    version = "5.7.1"
  }
}

variable "parent_domain_name" {
  description = "parent domain name for CI"
  type        = string
}

variable "ui_access_cidr_block" {
  description = "cidr block from which UI requests will be received"
  type        = string
}

variable "whitelist_cidr_blocks" {
  description = "list of allowed cidr blocks"
  type        = list(string)
}

variable "ami_filter_name" {
  type    = string
  default = "name"
}

variable "ami_filter_values" {
  type    = list(string)
  default = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
}

variable "ami_owners" {
  type    = list(string)
  default = ["self", "amazon"]
}

variable "concourse_no_proxy" {
  type    = string
  default = "169.254.169.254,169.254.169.123,.amazonaws.com"
}

variable "packer_egress_test_zip" {
  type = object({
    base_path = string
    version   = string
  })
}

variable "github_vpc" {
  type = object({
    id         = string
    owner      = string
    cidr_block = string
    region     = string
  })
  default = {
    id         = ""
    owner      = ""
    cidr_block = ""
    region     = ""
  }
}
