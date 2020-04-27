data "http" "github" {
  url = "https://api.github.com/meta"
}

locals {
  http_response = jsondecode(data.http.github.body)
}

resource "aws_wafregional_ipset" "github_com_ipset" {
  name = "match-github-com-ip"

  dynamic "ip_set_descriptor" {
    for_each = local.http_response.hooks

    content {
      value = ip_set_descriptor.value
      type  = "IPV4"
    }
  }
}
