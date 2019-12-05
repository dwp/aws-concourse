locals {
  cloudwatch_agent_config_file = templatefile(
    "${path.module}/templates/cloudwatch_agent_config.json",
    {
      cloudwatch_log_group : var.log_group.name
    }
  )

}

resource "aws_ssm_parameter" "cloudwatch_agent_config_worker" {
  name  = "/${var.ssm_name_prefix}/worker-cloudwatch_agent_config"
  type  = "String"
  value = local.cloudwatch_agent_config_file
}
