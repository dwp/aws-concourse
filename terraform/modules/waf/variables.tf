variable "name" {
  description = "common name"
  type        = string
}

variable "whitelist_cidr_blocks" {}

variable "log_bucket" {}

variable "cloudwatch_log_group" {}
