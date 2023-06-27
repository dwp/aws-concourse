locals {
  logger_bootstrap_file = templatefile(
    "${path.module}/templates/logger_bootstrap.sh",
    {
      cloudwatch_agent_config_ssm_parameter = aws_ssm_parameter.cloudwatch_agent_config_worker.name
      https_proxy                           = var.proxy.https_proxy
    }
  )

  service_env_vars = merge(
    {
      CONCOURSE_EPHEMERAL = true
      CONCOURSE_WORK_DIR  = "/opt/concourse"

      CONCOURSE_TSA_HOST                  = "${var.internal_loadbalancer.fqdn}:${local.service_port}"
      CONCOURSE_TSA_PUBLIC_KEY            = "/etc/concourse/tsa_host_key.pub"
      CONCOURSE_TSA_WORKER_PRIVATE_KEY    = "/etc/concourse/worker_key"
      CONCOURSE_CERTS_DIR                 = "/etc/ssl/certs"
      CONCOURSE_RUNTIME                   = "containerd"
      CONCOURSE_CONTAINERD_NETWORK_POOL   = "172.16.0.0/16"
      CONCOURSE_CONTAINERD_MAX_CONTAINERS = "2000"
      CONCOURSE_LOG_LEVEL                 = "error"

      HTTP_PROXY  = var.proxy.http_proxy
      HTTPS_PROXY = var.proxy.https_proxy
      NO_PROXY    = "${var.proxy.no_proxy},${var.internal_loadbalancer.fqdn}"
      http_proxy  = var.proxy.http_proxy
      https_proxy = var.proxy.https_proxy
      no_proxy    = "${var.proxy.no_proxy},${var.internal_loadbalancer.fqdn}"
    },
    var.worker.environment_override
  )

  worker_systemd_file = templatefile(
    "${path.module}/templates/worker_systemd",
    {
      environment_vars = local.service_env_vars
    }
  )

  worker_upstart_file = templatefile(
    "${path.module}/templates/worker_upstart",
    {
      environment_vars = local.service_env_vars
    }
  )

  worker_bootstrap_file = templatefile(
    "${path.module}/templates/worker_bootstrap.sh",
    {
      aws_default_region      = data.aws_region.current.name
      http_proxy              = var.proxy.http_proxy
      https_proxy             = var.proxy.https_proxy
      no_proxy                = "${var.proxy.no_proxy},${var.internal_loadbalancer.fqdn}"
      enterprise_github_certs = join(" ", var.enterprise_github_certs)
      name                    = local.name
      tsa_host_pub_key        = var.concourse_worker_config.tsa_host_pub_key
      worker_key              = var.concourse_worker_config.worker_key
      proxy_host              = var.proxy_host
      proxy_port              = var.proxy_port
      hcs_environment         = local.hcs_environment[local.environment]
      install_tenable         = var.install_tenable
      install_trend           = var.install_trend
      install_tanium          = var.install_tanium
      tanium_server_1         = var.tanium_server_1
      tanium_server_2         = var.tanium_server_2
      tanium_env              = var.tanium_env
      tanium_port             = var.tanium_port_1
      tanium_log_level        = var.tanium_log_level
      tenant                  = var.tenant
      tenantid                = var.tenantid
      token                   = var.token
      policyid                = var.policyid
    }
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

data "template_cloudinit_config" "worker_bootstrap" {
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

    content = <<EOF
write_files:
  - encoding: b64
    content: ${base64encode(local.worker_upstart_file)}
    owner: root:root
    path: /etc/init/concourse-worker.conf
    permissions: '0644'
  - encoding: b64
    content: ${base64encode(local.worker_systemd_file)}
    owner: root:root
    path: /etc/systemd/system/concourse-worker.service
    permissions: '0644'
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
    content      = local.worker_bootstrap_file
  }

  part {
    content_type = "text/x-shellscript"
    content      = local.logger_bootstrap_file
  }
}
