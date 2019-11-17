resource "aws_autoscaling_group" "web" {
  name             = local.name
  max_size         = var.web.count
  min_size         = var.web.count
  desired_capacity = var.web.count

  vpc_zone_identifier = var.vpc.aws_subnets_private[*].id

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "web" {
  name_prefix                          = "${local.name}-"
  image_id                             = var.ami_id
  instance_type                        = var.web.instance_type
  user_data                            = data.template_cloudinit_config.web_bootstrap.rendered
  instance_initiated_shutdown_behavior = "terminate"
  tags                                 = merge(var.tags, { Name = local.name })

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 32
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    no_device   = true
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.web.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = local.name })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, { Name = local.name })
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true

    security_groups = [
      aws_security_group.web.id
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}
