locals {
  fqdn = join(".", [var.name, var.parent_domain_name])
}
