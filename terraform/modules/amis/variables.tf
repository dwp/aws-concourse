variable "ami_filter_name" {
  type = string
}

variable "ami_filter_values" {
  type = list(string)
}

variable "ami_owners" {
  type    = list(string)
  default = ["self", "amazon"]
}
