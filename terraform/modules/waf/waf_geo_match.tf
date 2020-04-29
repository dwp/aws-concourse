resource "aws_wafregional_geo_match_set" "gb" {
  name = "geo_match_set"

  ## UCFS traffic originates from GB
  geo_match_constraint {
    type  = "Country"
    value = "GB"
  }

  ## github.com (for webhook traffic) is located in the US
  geo_match_constraint {
    type  = "Country"
    value = "US"
  }
}
