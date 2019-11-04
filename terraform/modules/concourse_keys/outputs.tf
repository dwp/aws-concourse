output "outputs" {
  value = {
    session_signing_key     = aws_ssm_parameter.session_signing_key.name
    session_signing_pub_key = aws_ssm_parameter.session_signing_pub_key.name
    tsa_host_key            = aws_ssm_parameter.tsa_host_key.name
    tsa_host_pub_key        = aws_ssm_parameter.tsa_host_pub_key.name
    worker_key              = aws_ssm_parameter.worker_key.name
    worker_pub_key          = aws_ssm_parameter.worker_pub_key.name
    authorized_worker_keys  = aws_ssm_parameter.authorized_worker_keys.name
  }
}
