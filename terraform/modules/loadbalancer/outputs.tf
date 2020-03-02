output "outputs" {
  value = {
    fqdn              = aws_route53_record.concourse.fqdn
    security_group_id = aws_security_group.lb.id
    arn               = aws_lb.lb.arn
  }
}
