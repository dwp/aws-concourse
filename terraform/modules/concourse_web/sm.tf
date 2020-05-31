data "aws_secretsmanager_secret" "dataworks-secrets" {
  name = "/concourse/dataworks/dataworks-secrets"
}

data "aws_secretsmanager_secret_version" "dataworks-secrets" {
  secret_id = data.aws_secretsmanager_secret.dataworks-secrets.id
}

data "aws_secretsmanager_secret" "concourse-secrets" {
  name = "/concourse/dataworks/dataworks"
}

data "aws_secretsmanager_secret_version" "concourse-secrets" {
  secret_id = data.aws_secretsmanager_secret.concourse-secrets.id
}
