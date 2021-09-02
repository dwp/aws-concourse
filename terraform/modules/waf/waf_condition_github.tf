
resource "aws_wafregional_ipset" "github_com_ipset" {
  name = "match-github-com-ip"

  dynamic "ip_set_descriptor" {
    for_each = var.github_metadata

    content {
      value = ip_set_descriptor.value
      type  = "IPV4"
    }
  }
}

resource "aws_wafregional_rule" "detect_github_access" {
  name        = "detect-github-access"
  metric_name = "detectgithubaccess"

  predicate {
    data_id = aws_wafregional_ipset.github_com_ipset.id
    negated = false
    type    = "IPMatch"
  }
}
