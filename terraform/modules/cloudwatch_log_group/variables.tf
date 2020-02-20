variable "name" {
  description = "common name"
  type        = string
}

variable "tags" {
  description = "tags to apply to aws resource"
  type        = map(string)
}

variable "group_name" {
  description = "log group name"
  type        = string
}

variable "retention_in_days" {
  description = "retention in days"
  type        = number
}
