resource "aws_iam_role" "web" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.web.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "web" {
  name = aws_iam_role.web.name
  role = aws_iam_role.web.id
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logging" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.web.id
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.web.id
}

# This used to be provided by the deprecated SSM role, so now added explicitly
resource "aws_iam_role_policy_attachment" "s3readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.web.id
}

data "aws_iam_policy_document" "web" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "concourse_parameters_web" {
  statement {
    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "concourse_parameters_web" {
  policy_arn = aws_iam_policy.concourse_parameters_web.arn
  role       = aws_iam_role.web.id
}

resource "aws_iam_policy" "concourse_parameters_web" {
  name        = "${local.name}ParameterStoreAccess"
  description = "Access to SSM for Web Nodes"
  policy      = data.aws_iam_policy_document.concourse_parameters_web.json
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

resource "aws_iam_role_policy_attachment" "concourse_web_secrets" {
  policy_arn = aws_iam_policy.concourse_secrets_read.arn
  role       = aws_iam_role.web.id
}

data "aws_iam_policy_document" "concourse_web_tag_ec2" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:CreateTags"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "concourse_web_tag_ec2" {
  name        = "${local.name}EC2"
  description = "Change Concourse Web's Tags"
  policy      = data.aws_iam_policy_document.concourse_web_tag_ec2.json
}

resource "aws_iam_role_policy_attachment" "concourse_web_tag_ec2" {
  policy_arn = aws_iam_policy.concourse_web_tag_ec2.arn
  role       = aws_iam_role.web.id
}

resource "aws_iam_role_policy_attachment" "CiAllowAssumeRoleWeb" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/CiAllowAssumeRole"
  role       = aws_iam_role.web.id
}

resource "aws_iam_role_policy_attachment" "TerraformDependenciesWeb" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/TerraformDependencies"
  role       = aws_iam_role.web.id
}

resource "aws_iam_role_policy_attachment" "AllowCiToRunTerraformWeb" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AllowCiToRunTerraform"
  role       = aws_iam_role.web.id
}

resource "aws_iam_role_policy_attachment" "RemoteStateWriteWeb" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/RemoteStateWrite"
  role       = aws_iam_role.web.id
}
