locals {
  logger_bootstrap_file = file("${path.module}/files/logger_bootstrap.sh")
  logger_systemd_file   = file("${path.module}/files/logger_systemd")

  logger_conf_file = templatefile(
    "${path.module}/templates/journald-cloudwatch-logs.conf",
    {
      cloudwatch_log_group = var.log_group.name
    }
  )

  worker_systemd_file = templatefile(
    "${path.module}/templates/worker_systemd",
    {
      environment_vars = merge(
        {
          CONCOURSE_EPHEMERAL = true
          CONCOURSE_WORK_DIR  = "/opt/concourse"

          CONCOURSE_TSA_HOST               = "${var.loadbalancer.fqdn}:${local.service_port}"
          CONCOURSE_TSA_PUBLIC_KEY         = "/etc/concourse/tsa_host_key.pub"
          CONCOURSE_TSA_WORKER_PRIVATE_KEY = "/etc/concourse/worker_key"
        },
        var.worker.environment_override
      )
    }
  )

  worker_bootstrap_file = templatefile(
    "${path.module}/templates/worker_bootstrap.sh",
    {
      concourse_version       = var.concourse.version
      aws_default_region      = data.aws_region.current.name
      tsa_host_pub_key_ssm_id = var.concourse_keys.tsa_host_pub_key
      worker_key_ssm_id       = var.concourse_keys.worker_key
    }
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
  - awscli
  - jq
EOF
  }

  part {
    content_type = "text/cloud-config"

    content = <<EOF
write_files:
  - encoding: b64
    content: ${base64encode(local.worker_systemd_file)}
    owner: root:root
    path: /etc/systemd/system/concourse-worker.service
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
    content      = local.worker_bootstrap_file
  }

  part {
    content_type = "text/x-shellscript"
    content      = local.logger_bootstrap_file
  }
}
