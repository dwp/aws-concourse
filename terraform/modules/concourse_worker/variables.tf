variable "name" {
  description = "common name"
  type        = string
}

variable "tags" {
  description = "tags to apply to aws resource"
  type        = map(string)
}

variable "ami_id" {}
variable "concourse" {}
variable "concourse_keys" {}
variable "loadbalancer" {}
variable "log_group" {}
variable "vpc" {}

variable "worker" {
  description = "worker configuration options"
  type = object({
    instance_type        = string
    count                = number
    environment_override = map(string)
  })
  default = {
    instance_type        = "t3.micro"
    count                = 3
    environment_override = {}
  }
}
