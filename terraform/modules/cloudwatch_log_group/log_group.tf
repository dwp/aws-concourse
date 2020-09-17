resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/${var.name}/${var.group_name}"
  retention_in_days = var.retention_in_days

  lifecycle {
    prevent_destroy = false
  }
}
