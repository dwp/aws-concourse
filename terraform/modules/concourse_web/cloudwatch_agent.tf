locals {
  cloudwatch_agent_config_file = templatefile(
    "${path.module}/templates/cloudwatch_agent_config.json",
    {
      cloudwatch_log_group = var.log_group.name,
      cloudwatch_namespace = var.name
    }
  )
}

resource "aws_ssm_parameter" "cloudwatch_agent_config_web" {
  name  = "/${var.ssm_name_prefix}/web-cloudwatch_agent_config"
  type  = "String"
  value = local.cloudwatch_agent_config_file
}
