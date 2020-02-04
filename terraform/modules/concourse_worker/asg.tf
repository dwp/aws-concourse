resource "aws_autoscaling_group" "worker" {
  name             = local.name
  max_size         = var.worker.count
  min_size         = var.worker.count
  desired_capacity = var.worker.count

  vpc_zone_identifier = var.vpc.aws_subnets_private[*].id

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]

}

resource "aws_launch_template" "worker" {
  name_prefix                          = "${local.name}-"
  image_id                             = var.ami_id
  instance_type                        = var.worker.instance_type
  user_data                            = data.template_cloudinit_config.worker_bootstrap.rendered
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
    arn = aws_iam_instance_profile.worker.arn
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
      aws_security_group.worker.id
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "worker_night" {
  scheduled_action_name  = "night"
  autoscaling_group_name = aws_autoscaling_group.worker.name
  recurrence             = var.asg_night.time

  min_size         = var.asg_night.min_size
  max_size         = var.asg_night.max_size
  desired_capacity = var.asg_night.desired_capacity
}

resource "aws_autoscaling_schedule" "worker_day" {
  scheduled_action_name  = "day"
  autoscaling_group_name = aws_autoscaling_group.worker.name
  recurrence             = var.asg_day.time

  min_size         = var.asg_day.min_size
  max_size         = var.asg_day.max_size
  desired_capacity = var.asg_day.desired_capacity
}
