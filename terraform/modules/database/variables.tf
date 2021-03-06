variable "name" {
  description = "common name"
  type        = string
}

variable "tags" {
  description = "tags to apply to aws resource"
  type        = map(string)
}

variable "vpc" {}

variable "database" {
  description = "database configuration options"

  type = object({
    instance_type           = string
    db_count                = number
    engine                  = string
    engine_version          = string
    backup_retention_period = number
    preferred_backup_window = string
  })

  default = {
    instance_type           = "db.t3.medium"
    db_count                = 1
    engine                  = "aurora-postgresql"
    engine_version          = "10.11"
    backup_retention_period = 14
    preferred_backup_window = "01:00-03:00"
  }
}

variable "database_credentials" {
  type = object({
    username = string,
    password = string,
  })
}
