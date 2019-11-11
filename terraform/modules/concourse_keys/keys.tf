resource "random_uuid" "uuid" {}

resource "tls_private_key" "session_signing" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_private_key" "tsa_host" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_private_key" "worker" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_ssm_parameter" "session_signing_key" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-session_signing_key"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = join("", tls_private_key.session_signing.*.private_key_pem)
}

resource "aws_ssm_parameter" "session_signing_pub_key" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-session_signing_pub_key"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = join("", tls_private_key.session_signing.*.public_key_openssh)
}

resource "aws_ssm_parameter" "tsa_host_key" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-tsa_host_key"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = join("", tls_private_key.tsa_host.*.private_key_pem)
}

resource "aws_ssm_parameter" "tsa_host_pub_key" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-tsa_host_pub_key"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = join("", tls_private_key.tsa_host.*.public_key_openssh)
}

resource "aws_ssm_parameter" "worker_key" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-worker_key"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = join("", tls_private_key.worker.*.private_key_pem)
}

resource "aws_ssm_parameter" "worker_pub_key" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-worker_pub_key"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = join("", tls_private_key.worker.*.public_key_openssh)
}

resource "aws_ssm_parameter" "authorized_worker_keys" {
  name   = "/${var.ssm_name_prefix}/${random_uuid.uuid.result}-authorized_worker_keys"
  type   = "SecureString"
  key_id = var.kms_key_id
  value  = join("", tls_private_key.worker.*.public_key_openssh)
}
