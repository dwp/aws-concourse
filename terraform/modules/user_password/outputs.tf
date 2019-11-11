output "outputs" {
  value = {
    user_ssm_name     = aws_ssm_parameter.user.name
    password_ssm_name = aws_ssm_parameter.password.name
  }
}
