output "outputs" {
  value = {
    username = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)[join("_", [var.credentials_type, "user"])]
    password = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)[join("_", [var.credentials_type, "password"])]
  }
}
