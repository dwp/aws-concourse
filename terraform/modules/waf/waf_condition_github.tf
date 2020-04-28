
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

resource "aws_wafregional_size_constraint_set" "github_com_size_restrictions" {
  name = "github-com-size-restrictions"

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "16384"

    field_to_match {
      type = "BODY"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "4093"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "1024"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  size_constraints {
    text_transformation = "NONE"
    comparison_operator = "GT"
    size                = "512"

    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_wafregional_rule" "github_com_restrict_sizes" {
  name        = "restrict-sizes"
  metric_name = "restrictsizes"

  predicate {
    data_id = aws_wafregional_ipset.github_com_ipset.id
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_size_constraint_set.github_com_size_restrictions.id
    negated = false
    type    = "SizeConstraint"
  }
}
