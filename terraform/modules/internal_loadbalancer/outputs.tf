output "outputs" {
  value = {
    fqdn = aws_route53_record.concourse.fqdn
  }
}
