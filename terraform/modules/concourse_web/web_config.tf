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
      CONCOURSE_CLUSTER_NAME  = var.name
      CONCOURSE_EXTERNAL_URL  = "https://${var.loadbalancer.fqdn}"
      CONCOURSE_AUTH_DURATION = var.auth_duration

      CONCOURSE_POSTGRES_DATABASE = var.database.database_name
      CONCOURSE_POSTGRES_HOST     = var.database.endpoint

      CONCOURSE_SESSION_SIGNING_KEY = "/etc/concourse/session_signing_key"
      CONCOURSE_TSA_AUTHORIZED_KEYS = "/etc/concourse/authorized_worker_keys"
      CONCOURSE_TSA_HOST_KEY        = "/etc/concourse/host_key"
      CONCOURSE_TSA_LOG_LEVEL       = "error"
      CONCOURSE_LOG_LEVEL           = "error"

      #TODO: Setup Monitoring !10
      CONCOURSE_PROMETHEUS_BIND_IP   = "0.0.0.0"
      CONCOURSE_PROMETHEUS_BIND_PORT = 9090

      CONCOURSE_AWS_SECRETSMANAGER_REGION                   = data.aws_region.current.name
      CONCOURSE_AWS_SECRETSMANAGER_PIPELINE_SECRET_TEMPLATE = "/concourse/{{.Team}}/{{.Pipeline}}/{{.Secret}}"
      CONCOURSE_AWS_SECRETSMANAGER_TEAM_SECRET_TEMPLATE     = "/concourse/{{.Team}}/{{.Secret}}"
      CONCOURSE_SECRET_CACHE_DURATION                       = "1m"
      CONCOURSE_ENABLE_RESOURCE_CAUSALITY                   = true

      # Cognito Auth
      CONCOURSE_OIDC_DISPLAY_NAME    = var.cognito_name
      CONCOURSE_OIDC_CLIENT_ID       = var.cognito_client_id
      CONCOURSE_OIDC_CLIENT_SECRET   = var.cognito_client_secret
      CONCOURSE_OIDC_ISSUER          = var.cognito_issuer
      CONCOURSE_OIDC_GROUPS_KEY      = "cognito:groups"
      CONCOURSE_OIDC_USER_NAME_KEY   = "cognito:username"
      CONCOURSE_MAIN_TEAM_OIDC_USER  = var.concourse_web_config.concourse_user
      CONCOURSE_MAIN_TEAM_OIDC_GROUP = "admins"

      # UC GitHub Auth
      CONCOURSE_GITHUB_HOST = var.concourse_web_config.enterprise_github_url

      CONCOURSE_METRICS_HOST_NAME     = local.name
      CONCOURSE_CAPTURE_ERROR_METRICS = true

      #TODO: Audit logging
      CONCOURSE_ENABLE_BUILD_AUDITING     = true
      CONCOURSE_ENABLE_CONTAINER_AUDITING = true
      CONCOURSE_ENABLE_JOB_AUDITING       = true
      CONCOURSE_ENABLE_PIPELINE_AUDITING  = true
      CONCOURSE_ENABLE_RESOURCE_AUDITING  = true
      CONCOURSE_ENABLE_SYSTEM_AUDITING    = true
      CONCOURSE_ENABLE_TEAM_AUDITING      = true
      CONCOURSE_ENABLE_WORKER_AUDITING    = true
      CONCOURSE_ENABLE_VOLUME_AUDITING    = true

      CONCOURSE_CONTAINER_PLACEMENT_STRATEGY = "random"

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
          CONCOURSE_PEER_ADDRESS = "127.0.0.1"
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
      aws_default_region                    = data.aws_region.current.name
      http_proxy                            = var.proxy.http_proxy
      https_proxy                           = var.proxy.https_proxy
      no_proxy                              = var.proxy.no_proxy
      enterprise_github_certs               = join(" ", var.enterprise_github_certs)
      name                                  = local.name
      concourse_user                        = var.concourse_web_config.concourse_user
      concourse_password                    = var.concourse_web_config.concourse_password
      database_user                         = var.concourse_web_config.database_username
      database_password                     = var.concourse_web_config.database_password
      enterprise_github_oauth_client_id     = var.concourse_web_config.enterprise_github_oauth_client_id
      enterprise_github_oauth_client_secret = var.concourse_web_config.enterprise_github_oauth_client_secret
      session_signing_key                   = var.concourse_web_config.session_signing_key
      tsa_host_key                          = var.concourse_web_config.tsa_host_key
      authorized_worker_keys                = var.concourse_web_config.authorized_worker_keys
      proxy_host                            = var.proxy_host
      proxy_port                            = var.proxy_port
      hcs_environment                       = local.hcs_environment[local.environment]
      install_tenable                       = var.install_tenable
      install_trend                         = var.install_trend
      install_tanium                        = var.install_tanium
      tanium_server_1                       = var.tanium_server_1
      tanium_server_2                       = var.tanium_server_2
      tanium_env                            = var.tanium_env
      tanium_port                           = var.tanium_port_1
      tanium_log_level                      = var.tanium_log_level
      tenant                                = var.tenant
      tenantid                              = var.tenantid
      token                                 = var.token
      policyid                              = var.policyid
      /* linuxPlatform                         = var.linuxPlatform */

    }
  )

  teams = templatefile(
    "${path.module}/templates/teams.sh",
    {
      aws_default_region = data.aws_region.current.name
      target             = "aws-concourse"
      concourse_user     = var.concourse_web_config.concourse_user
      concourse_password = var.concourse_web_config.concourse_password
    }
  )

  dataworks = templatefile(
    "${path.module}/templates/teams/dataworks/team.yml",
    {}
  )

  identity = templatefile(
    "${path.module}/templates/teams/identity/team.yml",
    {}
  )

  utility = templatefile(
    "${path.module}/templates/teams/utility/team.yml",
    {}
  )

  sre = templatefile(
    "${path.module}/templates/teams/sre/team.yml",
    {}
  )

  healthcheck_file = templatefile(
    "${path.module}/templates/healthcheck.sh",
    {}
  )

  config_hcs_file = templatefile(
    "${path.module}/templates/config_hcs.sh",
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
    content: ${base64encode(local.identity)}
    owner: root:root
    path: /root/teams/identity/team.yml
    permissions: '0600'
  - encoding: b64
    content: ${base64encode(local.utility)}
    owner: root:root
    path: /root/teams/utility/team.yml
    permissions: '0600'
  - encoding: b64
    content: ${base64encode(local.sre)}
    owner: root:root
    path: /root/teams/sre/team.yml
    permissions: '0600'
  - encoding: b64
    content: ${base64encode(local.healthcheck_file)}
    owner: root:root
    path: /home/root/healthcheck.sh
    permissions: '0700'
  - encoding: b64
    content: ${base64encode(local.config_hcs_file)}
    owner: root:root
    path: /opt/concourse/config_hcs.sh
    permissions: '0755'
EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = local.web_bootstrap_file
  }

  part {
    content_type = "text/x-shellscript"
    content      = local.teams
  }

  part {
    content_type = "text/x-shellscript"
    content      = local.logger_bootstrap_file
  }

  part {
    content_type = "text/plain"
    content      = local.dataworks
  }

  part {
    content_type = "text/plain"
    content      = local.identity
  }

  part {
    content_type = "text/plain"
    content      = local.utility
  }

  part {
    content_type = "text/plain"
    content      = local.sre
  }

}
