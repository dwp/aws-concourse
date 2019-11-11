variable "ssm_name_prefix" {
  description = "name prefix for ssm parameter store"
  type        = string
}

variable "kms_key_id" {
  description = "kms key for encrypting strings"
  type        = string
  default     = "alias/aws/ssm"
}
