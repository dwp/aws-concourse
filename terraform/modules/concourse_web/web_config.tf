locals {
  logger_bootstrap_file = templatefile(
    "${path.module}/templates/logger_bootstrap.sh",
    {
      cloudwatch_agent_config_ssm_parameter = aws_ssm_parameter.cloudwatch_agent_config_web.name
      https_proxy                           = var.proxy.https_proxy
    }
  )

  service_env_vars = merge(
    {
      CONCOURSE_CLUSTER_NAME = var.name
      CONCOURSE_EXTERNAL_URL = "https://${var.loadbalancer.fqdn}"

      CONCOURSE_ADD_LOCAL_USER       = "${var.concourse_secrets.username}:${var.concourse_secrets.password}"
      CONCOURSE_MAIN_TEAM_LOCAL_USER = var.concourse_secrets.username

      CONCOURSE_POSTGRES_DATABASE = var.database.database_name
      CONCOURSE_POSTGRES_HOST     = var.database.endpoint
      CONCOURSE_POSTGRES_PASSWORD = var.database_secrets.password
      CONCOURSE_POSTGRES_USER     = var.database_secrets.username

      CONCOURSE_SESSION_SIGNING_KEY = "/etc/concourse/session_signing_key"
      CONCOURSE_TSA_AUTHORIZED_KEYS = "/etc/concourse/authorized_worker_keys"
      CONCOURSE_TSA_HOST_KEY        = "/etc/concourse/host_key"

      #TODO: Setup Monitoring !10
      CONCOURSE_PROMETHEUS_BIND_IP   = "0.0.0.0"
      CONCOURSE_PROMETHEUS_BIND_PORT = 9090

      CONCOURSE_AWS_SECRETSMANAGER_REGION = data.aws_region.current.name
      CONCOURSE_AWS_SECRETSMANAGER_PIPELINE_SECRET_TEMPLATE : "/concourse/{{.Team}}/{{.Pipeline}}/{{.Secret}}"
      CONCOURSE_AWS_SECRETSMANAGER_TEAM_SECRET_TEMPLATE : "/concourse/{{.Team}}/{{.Secret}}"

      # Cognito Auth
      CONCOURSE_OIDC_DISPLAY_NAME  = var.cognito_name
      CONCOURSE_OIDC_CLIENT_ID     = var.cognito_client_id
      CONCOURSE_OIDC_CLIENT_SECRET = var.cognito_client_secret
      CONCOURSE_OIDC_ISSUER        = var.cognito_issuer
      CONCOURSE_OIDC_GROUPS_KEY    = "cognito:groups"
      CONCOURSE_OIDC_USER_NAME_KEY = "cognito:username"

      # UC GitHub Auth
      CONCOURSE_GITHUB_CLIENT_ID     = jsondecode(data.aws_secretsmanager_secret_version.concourse-github-auth.secret_binary)["enterprise_github_oauth_client_id"]
      CONCOURSE_GITHUB_CLIENT_SECRET = jsondecode(data.aws_secretsmanager_secret_version.concourse-github-auth.secret_binary)["enterprise_github_oauth_client_secret"]
      CONCOURSE_GITHUB_HOST          = jsondecode(data.aws_secretsmanager_secret_version.concourse-secrets.secret_binary)["enterprise_github_url"]

      CONCOURSE_METRICS_HOST_NAME     = "${local.name}"
      CONCOURSE_CAPTURE_ERROR_METRICS = true

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

      CONCOURSE_CONTAINER_PLACEMENT_STRATEGY : "random"

      HTTP_PROXY  = var.proxy.http_proxy
      HTTPS_PROXY = var.proxy.https_proxy
      NO_PROXY    = var.proxy.no_proxy
      http_proxy  = var.proxy.http_proxy
      https_proxy = var.proxy.https_proxy
      no_proxy    = var.proxy.no_proxy
    },
    var.web.environment_override
  )

  web_systemd_file = templatefile(
    "${path.module}/templates/web_systemd",
    {
      environment_vars = merge(local.service_env_vars,
        {
          CONCOURSE_PEER_ADDRESS = "%H"
      })
    }
  )

  web_upstart_file = templatefile(
    "${path.module}/templates/web_upstart",
    {
      environment_vars = merge(local.service_env_vars,
        {
          CONCOURSE_PEER_ADDRESS = "$HOSTNAME"
      })
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
      http_proxy                    = var.proxy.http_proxy
      https_proxy                   = var.proxy.https_proxy
      no_proxy                      = var.proxy.no_proxy
      enterprise_github_certs       = "${join(" ", var.enterprise_github_certs)}"
    }
  )

  teams = templatefile(
    "${path.module}/templates/teams.sh",
    {
      target             = "aws-concourse"
      concourse_version  = var.concourse.version
      concourse_username = var.concourse_secrets.username
      concourse_password = var.concourse_secrets.password
    }
  )

  dataworks = templatefile(
    "${path.module}/templates/teams/dataworks/team.yml",
    {}
  )

  utility = templatefile(
    "${path.module}/templates/teams/utility/team.yml",
    {}
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
  - aws-cli
  - jq
EOF
  }

  part {
    content_type = "text/cloud-config"
    content      = <<EOF
write_files:
  - encoding: b64
    content: ${base64encode(local.web_upstart_file)}
    owner: root:root
    path: /etc/init/concourse-web.conf
    permissions: '0644'
  - encoding: b64
    content: ${base64encode(local.web_systemd_file)}
    owner: root:root
    path: /etc/systemd/system/concourse-web.service
    permissions: '0644'
  - encoding: b64
    content: ${base64encode(local.teams)}
    owner: root:root
    path: /root/teams.sh
    permissions: '0700'
  - encoding: b64
    content: ${base64encode(local.dataworks)}
    owner: root:root
    path: /root/teams/dataworks/team.yml
    permissions: '0600'
  - encoding: b64
    content: ${base64encode(local.utility)}
    owner: root:root
    path: /root/teams/utility/team.yml
    permissions: '0600'
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

  part {
    content_type = "text/x-shellscript"
    content      = local.teams
  }

  part {
    content_type = "text/plain"
    content      = local.dataworks
  }

  part {
    content_type = "text/plain"
    content      = local.utility
  }
}
