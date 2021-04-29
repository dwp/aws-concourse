resource "aws_security_group" "db" {
  name = "${var.name}-db"
  vpc_id = var.vpc.aws_vpc.id
  tags   = merge(var.tags, { Name = "${var.name}-db" })
}
