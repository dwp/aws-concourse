data "aws_secretsmanager_secret" "concourse-github-auth" {
  name = "/concourse/dataworks/dataworks-secret"
}

data "aws_secretsmanager_secret_version" "concourse-github-auth" {
  secret_id = data.aws_secretsmanager_secret.concourse-github-auth.id
}
