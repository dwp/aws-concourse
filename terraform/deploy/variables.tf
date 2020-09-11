variable "name" {
  description = "cluster name, used in dns"
  type        = string
  default     = "ci"
}

variable "lb_name" {
  description = "load balancer name"
  type        = string
  default     = "ci"
}

variable "concourse" {
  description = "concourse version to install"
  type        = map(string)

  default = {
    version = "6.4.1"
  }
}

variable "concourse_username" {
  type        = string
  description = "Username for local admin user"
}

variable "concourse_password" {
  type        = string
  description = "Password for local admin user"
}

variable "database_username" {
  type        = string
  description = "Username for Concourse database"
}

variable "database_password" {
  type        = string
  description = "Password for concourse database"
}

variable "enterprise_github_oauth_client_id" {
  type        = string
  description = "Password for local admin user"
}

variable "enterprise_github_oauth_client_secret" {
  type        = string
  description = "Username for Concourse database"
}

variable "enterprise_github_url" {
  type        = string
  description = "Password for concourse database"
}

variable "parent_domain_name" {
  description = "parent domain name for CI"
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

variable "costcode" {
  type    = string
  default = ""
}
