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
    cidr_block = any
  })
}
