variable "name" {
  description = "cluster name, used in dns"
  type        = string
  default     = "ci"
}

variable "tags" {
  description = "tags to apply to aws resource"
  type        = map(string)
}

variable "concourse" {
  description = "concourse version to install"
  type        = map(string)

  default = {
    version = "5.7.0"
  }
}

variable "parent_domain_name" {
  description = "parent domain name for CI"
  type        = string
}

variable "whitelist_cidr_blocks" {
  description = "list of allowed cidr blocks"
  type        = list(string)
}

variable "vpc" {
  description = "vpc configuration"

  type = object({
    cidr_block = string
  })
}
