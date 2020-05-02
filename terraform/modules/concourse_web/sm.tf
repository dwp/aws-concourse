data "aws_secretsmanager_secret" "concourse-github-auth" {
  # arn = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/concourse/main/binary"
  name = "/concourse/dataworks/dataworks-secret"
}

data "aws_secretsmanager_secret_version" "concourse-github-auth" {
  secret_id = data.aws_secretsmanager_secret.concourse-github-auth.id
}
