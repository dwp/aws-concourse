locals {
  fqdn = join(".", [var.lb_name, "int", var.parent_domain_name])
}
