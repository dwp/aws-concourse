resource "aws_iam_role" "web" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.web.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "web" {
  name = aws_iam_role.web.name
  role = aws_iam_role.web.id
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.web.id
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logging" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
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

data "aws_iam_policy_document" "concourse_secretsmanager" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:List*",
      "secretsmanager:Get*",
      "secretsmanager:Describe*"
    ]

    resources = [
      "arn:aws:secretsmanager:::secret:/concourse/*",
      "arn:aws:secretsmanager:::secret:/concourse/dataworks/*",
    ]
  }
}

resource "aws_iam_policy" "concourse_secretsmanager" {
  name        = "ConcourseSecretsReadOnly"
  description = "Concourse read only access to Secrets Manager"
  policy      = data.aws_iam_policy_document.concourse_secretsmanager.json
}

resource "aws_iam_role_policy_attachment" "concourse_secretsmanager" {
  policy_arn = aws_iam_policy.concourse_secretsmanager.arn
  role       = aws_iam_role.web.id
}

data "aws_iam_policy_document" "concourse_kms" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    # TODO: Lock this down once we have a KMS key for Concourse secrets
    resources = [
      "arn:aws:kms:::*",
    ]
  }
}

resource "aws_iam_policy" "concourse_kms" {
  name        = "ConcourseKMSReadOnly"
  description = "Concourse decrypt access to secrets KMS key"
  policy      = data.aws_iam_policy_document.concourse_kms.json
}

resource "aws_iam_role_policy_attachment" "concourse_kms" {
  policy_arn = aws_iam_policy.concourse_kms.arn
  role       = aws_iam_role.web.id
}

resource "aws_iam_policy" "concourse_parameters" {
  name        = "${local.name}ParameterStoreAccess"
  description = "Access to SSM for Web Nodes"
  policy      = data.aws_iam_policy_document.concourse_parameters.json
}

data "aws_iam_policy_document" "concourse_parameters" {
  statement {
    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.name}*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "concourse_parameters" {
  policy_arn = aws_iam_policy.concourse_parameters.arn
  role       = aws_iam_role.web.id
}
