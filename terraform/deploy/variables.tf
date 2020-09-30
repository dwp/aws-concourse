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

variable "concourse_web_config" {
  type = object({
    database_username     = string,
    database_password     = string,
    enterprise_github_url = string,
  })
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
