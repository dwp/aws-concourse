variable clients {
  description = "List of named client/group pairs"
  type        = list(string)
}

variable domain {
  description = "Domain to use for cognito user pool"
  type        = string
}

variable root_dns_names {
  description = "Root dns names to use for cognito callback URLs"
  type        = list(string)
}
<<<<<<< HEAD

variable "loadbalancer" {}
=======
>>>>>>> a6322d1d36fe32be3ea7d04199f77604bc54fa9c
