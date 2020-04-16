data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "current" {}

data "aws_ssm_parameter" "database_user" {
  name = var.database_secrets.user_ssm_name
}

data "aws_ssm_parameter" "database_password" {
  name = var.database_secrets.password_ssm_name
}

data "aws_ssm_parameter" "concourse_user" {
  name = var.concourse_secrets.user_ssm_name
}

data "aws_ssm_parameter" "concourse_password" {
  name = var.concourse_secrets.password_ssm_name
}
