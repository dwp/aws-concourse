variable "name" {
  description = "common name"
  type        = string
}

variable "tags" {
  description = "tags to apply to aws resource"
  type        = map(string)
}

variable "ami_id" {}
variable "internal_loadbalancer" {}
variable "loadbalancer" {}
variable "log_group" {}
variable "vpc" {}
variable "ssm_name_prefix" {}
variable "concourse_web" {}

variable "concourse_worker_config" {
  type = object({
    tsa_host_pub_key = string,
    worker_key       = string,
  })
}

variable "worker" {
  description = "worker configuration options"
  type = object({
    instance_type        = string
    count                = number
    environment_override = map(string)
  })
  default = {
    instance_type        = "t3.micro"
    count                = 1
    environment_override = {}
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
  # TODO: 3's are not the correct night time value
  default = {
    min_size         = 3
    max_size         = 3
    desired_capacity = 3
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
    min_size         = 3
    max_size         = 3
    desired_capacity = 3
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
  default = ""
}

variable "dynamodb_prefix_list_id" {
  type    = string
  default = ""
}

variable "enterprise_github_certs" {
  type        = list(string)
  description = "A list of certificates that make up the full CA chain that sign the Enterprise GitHub TlS certificates"
  default     = []
}

variable "concourse_worker_role" {
  type        = string
  description = "Role name for the worker's instance profile"
}


variable "proxy_port" {
  description = "proxy port"
  type        = string
  default     = "3128"
}

variable "proxy_host" {
  description = "proxy host"
  type        = string
}
variable "tanium_server_1" {
  description = "tanium server 1"
  type        = string
}

variable "tanium_server_2" {
  description = "tanium server 2"
  type        = string
}

variable "tanium_port_1" {
  description = "tanium port 1"
  type        = string
  default     = "16563"
}

variable "tanium_port_2" {
  description = "tanium port 2"
  type        = string
  default     = "16555"
}

variable "tanium_env" {
  description = "tanium environment"
  type        = string
}

variable "tanium_log_level" {
  description = "tanium log level"
  type        = string
  default     = "41"
}

variable "install_tenable" {
  description = "Install Tenable"
  type        = bool
}

variable "install_trend" {
  description = "Install Trend"
  type        = bool
}

variable "install_tanium" {
  description = "Install Tanium"
  type        = bool
}

variable "tenantid" {
  description = "Trend tenant ID"
  type        = string
}

variable "token" {
  description = "Trend token"
  type        = string
}

variable "tenant" {
  description = "Trend tenant"
  type        = string
}

variable "policyid" {
  description = "Trend Policy ID"
  type        = string
}

variable "tanium_prefix" {
  description = "Tanium prefix"
  type        = list(string)
}

variable "config_bucket_id" {
  description = "Config bucket ID"
  type        = string
}

variable "config_bucket_arn" {
  description = "Config bucket arn"
  type        = string
}

variable "config_bucket_cmk_arn" {
  description = "Config bucket cmk arn"
  type        = string
}

variable "s3_scripts_bucket" {
  description = "S3 Scripts bucket"
  type        = string
}

variable "tanium_service_endpoint_id" {
  description = "Tanium Service Endpoint id"
  type        = string
}