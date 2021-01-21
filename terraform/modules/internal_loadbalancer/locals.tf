locals {
  fqdn = join(".", [var.lb_name, "local", var.parent_domain_name])
}
