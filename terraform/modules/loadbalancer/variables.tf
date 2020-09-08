variable "name" {
  description = "common name"
  type        = string
}

variable "lb_name" {
  description = "load balancer name"
  type        = string
}

variable "tags" {
  description = "tags to apply to aws resource"
  type        = map(string)
}

variable "concourse_web" {}
variable "parent_domain_name" {}
variable "vpc" {}
variable "wafregional_web_acl_id" {}
variable "whitelist_cidr_blocks" {}
variable "logging_bucket" {}