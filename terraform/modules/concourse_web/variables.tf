variable "name" {
  description = "common name"
  type        = string
}

variable "tags" {
  description = "tags to apply to aws resource"
  type        = map(string)
}

variable "ami_id" {}
variable "database" {}
variable "internal_loadbalancer" {}
variable "loadbalancer" {}
variable "log_group" {}
variable "vpc" {}
variable "ssm_name_prefix" {}
variable "cognito_client_secret" {}
variable "cognito_client_id" {}
variable "cognito_domain" {}
variable "cognito_issuer" {}
variable "cognito_name" {}

variable "concourse_web_config" {
  type = object({
    database_username                     = string,
    database_password                     = string,
    enterprise_github_url                 = string,
    concourse_user                        = string,
    concourse_password                    = string,
    enterprise_github_oauth_client_id     = string,
    enterprise_github_oauth_client_secret = string,
    session_signing_key                   = string,
    tsa_host_key                          = string,
    authorized_worker_keys                = string,
  })
}


variable "web" {
  description = "atc/tsa configuration options"

  type = object({
    count                 = number
    max_instance_lifetime = number
    instance_type         = string
    environment_override  = map(string)
  })

  default = {
    instance_type         = "t3.micro"
    max_instance_lifetime = 60 * 60 * 24 * 7
    count                 = 1
    environment_override  = {}
  }
}

variable "asg_night" {
  description = "asg night schedule configuration"

  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
    time             = string
  })

  default = {
    min_size         = 1
    max_size         = 1
    desired_capacity = 1
    time             = "0 19 * * 1-5"
  }
}

variable "asg_day" {
  description = "asg day schedule configuration"

  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
    time             = string
  })

  default = {
    min_size         = 1
    max_size         = 3
    desired_capacity = 1
    time             = "0 7 * * 1-5"
  }
}

variable "proxy" {
  type = map(string)
  default = {
    http_proxy  = ""
    https_proxy = ""
    no_proxy    = ""
  }
}

variable "github_cidr_block" {
  type    = string
  default = ""
}

variable "s3_prefix_list_id" {
  type    = string
  default = "pl-7ca54015"
}



variable "enterprise_github_certs" {
  type        = list(string)
  description = "A list of certificates that make up the full CA chain that sign the Enterprise GitHub TlS certificates"
  default     = []
}

variable "auth_duration" {
  type        = string
  description = "Length of time for which tokens are valid. Afterwards, users will have to log back in"
  default     = "12h"
}
