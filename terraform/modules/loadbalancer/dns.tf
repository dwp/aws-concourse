resource "aws_route53_record" "concourse" {
  name    = local.fqdn
  type    = "A"
  zone_id = data.aws_route53_zone.main.id

  alias {
    evaluate_target_health = false
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
  }
}

resource "aws_acm_certificate" "concourse" {
  domain_name       = local.fqdn
  validation_method = "DNS"
}

resource "aws_route53_record" "concourse_validation" {
  name    = tolist(aws_acm_certificate.concourse.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.concourse.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.main.id
  records = [tolist(aws_acm_certificate.concourse.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.concourse.arn
  validation_record_fqdns = [aws_route53_record.concourse_validation.fqdn]
}
