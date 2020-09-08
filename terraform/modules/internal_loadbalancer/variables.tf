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
variable "concourse_worker" {}
variable "parent_domain_name" {}
variable "vpc" {}
variable "whitelist_cidr_blocks" {}
variable "logging_bucket" {}

variable "concourse_internal_allowed_principals" {
  description = "A list of AWS principals that are allowed to reach Concourse via its internal load balancer"
  type        = list(string)
  default     = []
}
