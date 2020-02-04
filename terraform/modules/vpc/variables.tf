variable "name" {
  description = "common name"
  type        = string
}

variable "tags" {
  description = "tags to apply to aws resource"
  type        = map(string)
}

variable "vpc" {
  description = "vpc configurables"
  type = object({
    cidr_block = string
  })
}
variable "subnets" {
  description = "define sizes for subnets using Terraform cidrsubnet function. Defaults suit an empty /24 VPC"
  type = map(map(number))
  default = {
    public = {
      newbits = 4
      netnum = 0
    }
    private = {
      newbits = 2
      netnum = 1
    }
  }
}
