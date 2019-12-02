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
    min_size         = 3
    max_size         = 3
    desired_capacity = 3
    time             = "0 7 * * 1-5"
  }
}
