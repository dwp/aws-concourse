
resource "aws_wafregional_ipset" "github_com_ipset" {
  name = "match-github-com-ip"

  dynamic "ip_set_descriptor" {
    for_each = var.github_metadata.hooks

    content {
      value = ip_set_descriptor.value
      type  = "IPV4"
    }
  }
}
