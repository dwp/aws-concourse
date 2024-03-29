variable "clients" {
  description = "List of named client/group pairs"
  type        = list(string)
}

variable "domain" {
  description = "Domain to use for cognito user pool"
  type        = string
}

variable "root_dns_names" {
  description = "Root dns names to use for cognito callback URLs"
  type        = list(string)
}

variable "loadbalancer" {}
