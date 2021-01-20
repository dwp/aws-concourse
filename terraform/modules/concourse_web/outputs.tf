output "outputs" {
  value = {
    http_target_group_arn = aws_lb_target_group.web_http.arn
    int_http_target_group_arn = aws_lb_target_group.int_web_http.arn
    ssh_target_group_arn  = aws_lb_target_group.web_ssh.arn
    security_group        = aws_security_group.web
  }
}
