output "outputs" {
  value = {
    session_signing_key = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["session_signing_key"]
    session_signing_pub_key = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["session_signing_pub_key"]
    tsa_host_key = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["tsa_host_key"]
    tsa_host_pub_key = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["tsa_host_pub_key"]
    worker_key = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["worker_key"]
    worker_pub_key = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["worker_pub_key"]
    authorized_worker_keys = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["authorized_worker_keys"]
  }
}
