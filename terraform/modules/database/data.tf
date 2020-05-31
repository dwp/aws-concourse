data "aws_region" "current" {}
data "aws_availability_zones" "current" {}

data "aws_secretsmanager_secret_version" "dataworks-secrets" {
  secret_id = "/concourse/dataworks/dataworks-secrets"
}
