data "aws_region" "current" {}
data "aws_availability_zones" "current" {}

data "aws_ssm_parameter" "database_password" {
  name = var.secrets.password_ssm_name
}

data "aws_ssm_parameter" "database_user" {
  name = var.secrets.user_ssm_name
}
