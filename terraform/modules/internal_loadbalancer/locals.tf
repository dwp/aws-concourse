locals {
  fqdn = join(".", [var.name, "int", var.parent_domain_name])
}
