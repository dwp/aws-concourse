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

data "aws_iam_policy_document" "ci_user" {
  statement {
    effect = "Allow"

    actions = [
      "acm:*",
      "application-autoscaling:*",
      "athena:*",
      "cloudformation:*",
      "cloudhsm:*",
      "config:*",
      "dynamodb:*",
      "elasticmapreduce:*",
      "ecr:*",
      "ecs:*",
      "events:*",
      "firehose:*",
      "glue:*",
      "inspector:*",
      "kinesis:*",
      "cognito-idp:AddCustomAttributes",
      "cognito-idp:CreateGroup",
      "cognito-idp:CreateResourceServer",
      "cognito-idp:CreateUserPool",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:CreateUserPoolDomain",
      "cognito-idp:DeleteGroup",
      "cognito-idp:DeleteResourceServer",
      "cognito-idp:DeleteUserPool",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:DeleteUserPoolDomain",
      "cognito-idp:Describe*",
      "cognito-idp:Get*",
      "cognito-idp:List*",
      "cognito-idp:SetRiskConfiguration",
      "cognito-idp:SetUICustomization",
      "cognito-idp:TagResource",
      "cognito-idp:UntagResource",
      "cognito-idp:UpdateAuthEventFeedback",
      "cognito-idp:UpdateGroup",
      "cognito-idp:UpdateResourceServer",
      "cognito-idp:UpdateUserPool",
      "cognito-idp:UpdateUserPoolClient",
      "cognito-idp:UpdateUserPoolDomain",
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateAccessKey",
      "iam:CreateInstanceProfile",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteAccessKey",
      "iam:DeleteInstanceProfile",
      "iam:DeleteLoginProfile",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DeleteServerCertificate",
      "iam:DeleteServiceLinkedRole",
      "iam:DeleteUserPolicy",
      "iam:DetachRolePolicy",
      "iam:GenerateCredentialReport",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:Get*",
      "iam:List*",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:Simulate*",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAccessKey",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateServerCertificate",
      "iam:UploadServerCertificate",
      "route53resolver:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "ram:*",
      "rds:*",
      "s3:*",
      "ses:*",
      "secretsmanager:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "waf-regional:*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "DenyLogDeletion"
    effect = "Deny"

    actions = [
      "logs:DeleteDestination",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "DenyRestrictedActions"
    effect = "Deny"

    actions = [
      "cloudhsm:DeleteBackup",
      "iam:AttachUserPolicy",
      "iam:CreateUser",
      "iam:DetachUserPolicy",
      "iam:DeleteUser",
      "iam:PutUserPolicy",
      "ssm:StartSession",
      "ssm:ResumeSession",
      "acm:ExportCertificate",
      "acm-pca:ImportCertificateAuthorityCertificate",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ci_user" {
  name        = "CIUser"
  description = "CI user definition"
  policy      = data.aws_iam_policy_document.ci_user.json
}

resource "aws_iam_role_policy_attachment" "ci_user" {
  policy_arn = aws_iam_policy.ci_user.arn
  role       = aws_iam_role.web.id
}

data "aws_iam_policy_document" "remote_state_read_policy" {
  statement {
    sid    = "AllowReadRemoteState"
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Head*",
    ]

    resources = [
      "${lookup(var.remote_state, "bucket_arn")}",
      "${lookup(var.remote_state, "bucket_arn")}/*",
    ]
  }

  statement {
    sid    = "AllowRemoteStateEncryption"
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"

      values = [
        "${lookup(var.remote_state, "bucket_arn")}/*",
      ]
    }
  }

  statement {
    sid    = "AllowRemoteStateLocking"
    effect = "Allow"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "${lookup(var.remote_state, "dynamo_arn")}",
    ]
  }
}

resource "aws_iam_policy" "remote_state_read_policy" {
  name        = "RemoteStateRead"
  description = "Allows reading and locking of remote state"
  policy      = data.aws_iam_policy_document.remote_state_read_policy.json
}

resource "aws_iam_role_policy_attachment" "remote_state_read_policy" {
  policy_arn = aws_iam_policy.remote_state_read_policy.arn
  role       = aws_iam_role.web.id
}

data "aws_iam_policy_document" "terraform_dependencies" {
  statement {
    sid    = "TerraformDependencies"
    effect = "Allow"

    actions = [
      "ec2:DescribeAccountAttributes",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "TerraformUserDescribeSSMParameters"
    effect = "Allow"

    actions = [
      "ssm:DescribeParameters",
    ]

    resources = [
      "arn:aws:ssm:::*",
    ]
  }

  statement {
    sid    = "TerraformUserGetBootstrapConfig"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:::parameter/terraform_bootstrap_config",
    ]
  }
}

resource "aws_iam_policy" "terraform_dependencies" {
  name        = "TerraformDependencies"
  description = "Terraform attempts to inspect the environment, this prevents the false auth alarms"
  policy      = data.aws_iam_policy_document.terraform_dependencies.json
}

resource "aws_iam_role_policy_attachment" "terraform_dependencies" {
  policy_arn = aws_iam_policy.terraform_dependencies.arn
  role       = aws_iam_role.web.id
}

data "aws_iam_policy_document" "remote_state_write_policy" {
  statement {
    sid    = "RemoteStateS3"
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      "${lookup(var.remote_state, "bucket_arn")}",
      "${lookup(var.remote_state, "bucket_arn")}/*",
    ]
  }

  statement {
    sid    = "RemoteStateDynamoDB"
    effect = "Allow"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "${lookup(var.remote_state, "dynamo_arn")}",
    ]
  }

  statement {
    sid    = "RemoteStateKMS"
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"

      values = [
        "${lookup(var.remote_state, "bucket_arn")}/*",
      ]
    }
  }
}

resource "aws_iam_policy" "remote_state_write_policy" {
  name        = "RemoteStateWrite"
  description = "Allows writing to remote state"
  policy      = data.aws_iam_policy_document.remote_state_write_policy.json
}

resource "aws_iam_role_policy_attachment" "remote_state_write_policy" {
  policy_arn = aws_iam_policy.remote_state_write_policy.arn
  role       = aws_iam_role.web.id
}

data "aws_iam_policy_document" "ci_user_policy" {
  statement {
    sid    = "AllowCiToRunTerraform"
    effect = "Allow"

    actions = [
      "iam:GetUser",
    ]

    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }
}

resource "aws_iam_policy" "ci_user_policy" {
  name        = "AllowCiToRunTerraform"
  description = "Allows CI to perform some actions before assuming role"
  policy      = data.aws_iam_policy_document.ci_user_policy.json
}

resource "aws_iam_role_policy_attachment" "ci_user_policy" {
  policy_arn = aws_iam_policy.ci_user_policy.arn
  role       = aws_iam_role.web.id
}
