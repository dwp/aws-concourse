resource "random_uuid" "uuid" {}

resource "random_string" "user" {
  length  = 16
  special = false # RDS doesn't allow /,", and @
  number = false
}

resource "aws_ssm_parameter" "user" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-user"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = random_string.user.result
}

resource "random_string" "password" {
  length  = 32
  special = false # RDS doesn't allow /,", and @
}

resource "aws_ssm_parameter" "password" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-password"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = random_string.password.result
}
