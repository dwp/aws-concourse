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

variable "concourse_web_config" {
  type = object({
    concourse_username                    = string,
    concourse_password                    = string,
    database_username                     = string,
    database_password                     = string,
    enterprise_github_oauth_client_id     = string,
    enterprise_github_oauth_client_secret = string,
    enterprise_github_url                 = string,
  })
}

variable "concourse_keys" {
  type = object({
    session_signing_key     = string,
    session_signing_pub_key = string,
    tsa_host_key            = string,
    tsa_host_pub_key        = string,
    worker_key              = string,
    worker_pub_key          = string,
    authorized_worker_keys  = string,
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
