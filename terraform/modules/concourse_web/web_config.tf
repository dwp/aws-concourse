locals {
  logger_bootstrap_file = file("${path.module}/files/logger_bootstrap.sh")
  logger_systemd_file   = file("${path.module}/files/logger_systemd")

  logger_conf_file = templatefile(
    "${path.module}/templates/journald-cloudwatch-logs.conf",
    {
      cloudwatch_log_group = var.log_group.name
    }
  )

  web_systemd_file = templatefile(
    "${path.module}/templates/web_systemd",
    {
      environment_vars = merge(
        {
          CONCOURSE_CLUSTER_NAME = var.name
          CONCOURSE_EXTERNAL_URL = "https://${var.loadbalancer.fqdn}"
          CONCOURSE_PEER_ADDRESS = "%H"

          CONCOURSE_ADD_LOCAL_USER       = "${data.aws_ssm_parameter.concourse_user.value}:${data.aws_ssm_parameter.concourse_password.value}"
          CONCOURSE_MAIN_TEAM_LOCAL_USER = data.aws_ssm_parameter.concourse_user.value

          CONCOURSE_POSTGRES_DATABASE = var.database.database_name
          CONCOURSE_POSTGRES_HOST     = var.database.endpoint
          CONCOURSE_POSTGRES_PASSWORD = data.aws_ssm_parameter.database_password.value
          CONCOURSE_POSTGRES_USER     = data.aws_ssm_parameter.database_user.value

          CONCOURSE_SESSION_SIGNING_KEY = "/etc/concourse/session_signing_key"
          CONCOURSE_TSA_AUTHORIZED_KEYS = "/etc/concourse/authorized_worker_keys"
          CONCOURSE_TSA_HOST_KEY        = "/etc/concourse/host_key"

          #TODO: Setup Monitoring !10
          CONCOURSE_PROMETHEUS_BIND_IP   = "0.0.0.0"
          CONCOURSE_PROMETHEUS_BIND_PORT = 8081

          CONCOURSE_OIDC_DISPLAY_NAME  = var.cognito.name
          CONCOURSE_OIDC_CLIENT_ID     = data.aws_ssm_parameter.concourse_cognito_client_id.value
          CONCOURSE_OIDC_CLIENT_SECRET = data.aws_ssm_parameter.concourse_cognito_client_secret.value
          CONCOURSE_OIDC_ISSUER        = var.cognito.issuer

          CONCOURSE_MAIN_TEAM_OIDC_GROUP = var.cognito.admin_group

          #TODO: Audit logging
          #CONCOURSE_ENABLE_BUILD_AUDITING     = true
          #CONCOURSE_ENABLE_CONTAINER_AUDITING = true
          #CONCOURSE_ENABLE_JOB_AUDITING       = true
          #CONCOURSE_ENABLE_PIPELINE_AUDITING  = true
          #CONCOURSE_ENABLE_RESOURCE_AUDITING  = true
          #CONCOURSE_ENABLE_SYSTEM_AUDITING    = true
          #CONCOURSE_ENABLE_TEAM_AUDITING      = true
          #CONCOURSE_ENABLE_WORKER_AUDITING    = true
          #CONCOURSE_ENABLE_VOLUME_AUDITING    = true
        },
        var.web.environment_override
      )
    }
  )

  web_bootstrap_file = templatefile(
    "${path.module}/templates/web_bootstrap.sh",
    {
      authorized_worker_keys_ssm_id = var.concourse_keys.authorized_worker_keys
      aws_default_region            = data.aws_region.current.name
      concourse_version             = var.concourse.version
      session_signing_key_ssm_id    = var.concourse_keys.session_signing_key
      tsa_host_key_ssm_id           = var.concourse_keys.tsa_host_key
    }
  )
}

data "template_cloudinit_config" "web_bootstrap" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "package_update: true"
  }

  part {
    content_type = "text/cloud-config"
    content      = "package_upgrade: true"
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
packages:
  - awscli
  - jq
EOF
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
write_files:
  - encoding: b64
    content: ${base64encode(local.web_systemd_file)}
    owner: root:root
    path: /etc/systemd/system/concourse-web.service
    permissions: '0644'
  - encoding: b64
    content: ${base64encode(local.logger_conf_file)}
    owner: root:root
    path: /opt/journald-cloudwatch-logs/journald-cloudwatch-logs.conf
    permissions: '0644'
  - encoding: b64
    content: ${base64encode(local.logger_systemd_file)}
    owner: root:root
    path: /etc/systemd/system/journald-cloudwatch-logs.service
    permissions: '0644'
EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = local.web_bootstrap_file
  }

  part {
    content_type = "text/x-shellscript"
    content      = local.logger_bootstrap_file
  }
}
