data "aws_region" "current" {}
data "aws_availability_zones" "current" {}

data "aws_vpc_peering_connection" "prometheus_pcx" {
  tags = {
    Name = "prometheus_pcx"
  }
}
