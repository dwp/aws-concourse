data "aws_iam_role" "worker" {
  name = var.concourse_worker_role
}

resource "aws_iam_instance_profile" "concourse_worker" {
  name = data.aws_iam_role.worker.name
  role = data.aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = data.aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logging" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = data.aws_iam_role.worker.id
}

# This used to be provided by the deprecated SSM role, so now added explicitly
resource "aws_iam_role_policy_attachment" "s3readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.worker.id
}

data "aws_iam_policy_document" "concourse_parameters_worker" {
  statement {
    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }
}

resource "aws_iam_policy" "concourse_parameters_worker" {
  name        = "${local.name}ParameterStoreAccess"
  description = "Access to SSM for Web Nodes"
  policy      = data.aws_iam_policy_document.concourse_parameters_worker.json
}

resource "aws_iam_role_policy_attachment" "concourse_parameters_worker" {
  policy_arn = aws_iam_policy.concourse_parameters_worker.arn
  role       = data.aws_iam_role.worker.id
}

data "aws_iam_policy_document" "concourse_autoscaling_worker" {
  statement {
    actions = [
      "autoscaling:SetInstanceHealth"
    ]

    resources = [
      aws_autoscaling_group.worker.arn
    ]
  }
}

resource "aws_iam_policy" "concourse_autoscaling_worker" {
  name        = "${local.name}AutoScaling"
  description = "Change Concourse Worker's Instance Health"
  policy      = data.aws_iam_policy_document.concourse_autoscaling_worker.json
}

resource "aws_iam_role_policy_attachment" "concourse_autoscaling_worker" {
  policy_arn = aws_iam_policy.concourse_autoscaling_worker.arn
  role       = data.aws_iam_role.worker.id
}

data "aws_iam_policy_document" "concourse_secrets_read" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/concourse/*",
    ]
  }
}

resource "aws_iam_policy" "concourse_secrets_read" {
  name        = "${local.name}SecretsAccess"
  description = "Read-only access to Concourse Secrets"
  policy      = data.aws_iam_policy_document.concourse_secrets_read.json
}

resource "aws_iam_role_policy_attachment" "concourse_worker_secrets" {
  policy_arn = aws_iam_policy.concourse_secrets_read.arn
  role       = data.aws_iam_role.worker.id
}

data "aws_iam_policy_document" "concourse_tag_ec2" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:CreateTags"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "concourse_tag_ec2" {
  name        = "${local.name}EC2"
  description = "Change Concourse Worker's Tags"
  policy      = data.aws_iam_policy_document.concourse_tag_ec2.json
}

resource "aws_iam_role_policy_attachment" "concourse_tag_ec2" {
  policy_arn = aws_iam_policy.concourse_tag_ec2.arn
  role       = data.aws_iam_role.worker.id
}
