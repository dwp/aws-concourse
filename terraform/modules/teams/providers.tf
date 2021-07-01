terraform {
  required_providers {
    concourse = {
      source = "terraform-provider-concourse/concourse"
      version = "7.2.1"
    }
  }
}

provider "concourse" {
  url  = var.concourse_url
  team = "main"

  username = var.concourse_username
  password = var.concourse_password
}
