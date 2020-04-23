output "outputs" {
  value = {
    http_target_group_arn         = aws_lb_target_group.web_http.arn
    ssh_target_group_arn          = aws_lb_target_group.web_ssh.arn
    security_group                = aws_security_group.web
    ci_user_arn                   = aws_iam_policy.ci_user.arn
    remote_state_read_policy_arn  = aws_iam_policy.remote_state_read_policy.arn
    terraform_dependencies_arn    = aws_iam_policy.terraform_dependencies.arn
    remote_state_write_policy_arn = aws_iam_policy.remote_state_write_policy.arn
    ci_user_policy_arn            = aws_iam_policy.ci_user_policy.arn
  }
}
