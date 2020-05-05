data "aws_secretsmanager_secret" "concourse-github-auth" {
  name = "/concourse/dataworks/dataworks-secrets"
}

data "aws_secretsmanager_secret_version" "concourse-github-auth" {
  secret_id = data.aws_secretsmanager_secret.concourse-github-auth.id
}

data "aws_secretsmanager_secret" "concourse-secrets" {
  name = "/concourse/dataworks/dataworks"
}

data "aws_secretsmanager_secret_version" "concourse-secrets" {
  secret_id = data.aws_secretsmanager_secret.concourse-secrets.id
}
