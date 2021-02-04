resource "aws_autoscaling_group" "web" {
  name                  = local.name
  max_size              = var.web.count
  min_size              = var.web.count
  desired_capacity      = var.web.count
  max_instance_lifetime = var.web.max_instance_lifetime

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
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      max_size,
      target_group_arns
    ]
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
      volume_type           = local.ebs_volume_type_web[local.environment]
      volume_size           = local.ebs_volume_size_web[local.environment]
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

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
  }

}

resource "aws_autoscaling_schedule" "web_night" {
  scheduled_action_name  = "night"
  autoscaling_group_name = aws_autoscaling_group.web.name
  recurrence             = var.asg_night.time

  min_size         = var.asg_night.min_size
  max_size         = var.asg_night.max_size
  desired_capacity = var.asg_night.desired_capacity
}

resource "aws_autoscaling_schedule" "web_day" {
  scheduled_action_name  = "day"
  autoscaling_group_name = aws_autoscaling_group.web.name
  recurrence             = var.asg_day.time

  min_size         = var.asg_day.min_size
  max_size         = var.asg_day.max_size
  desired_capacity = var.asg_day.desired_capacity
}

resource "aws_autoscaling_policy" "web-scale-up" {
  name                   = "web-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 180
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_autoscaling_policy" "web-scale-down" {
  name                   = "web-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 180
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name          = "cpu-util-high-web"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors ec2 cpu for high utilization on web nodes"
  alarm_actions = [
    aws_autoscaling_policy.web-scale-up.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name          = "cpu-util-low-web"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "This metric monitors ec2 cpu for low utilization on agent hosts"
  alarm_actions = [
    aws_autoscaling_policy.web-scale-down.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}
