data "aws_iam_role" "worker" {
  name = var.concourse_worker_role
}

resource "aws_iam_instance_profile" "concourse_worker" {
  name = data.aws_iam_role.worker.name
  role = data.aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = data.aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logging" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = data.aws_iam_role.worker.id
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

data "aws_iam_policy_document" "concourse_lambda_invoke" {
  statement {
    actions = [
      "lambda:Invoke"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "concourse_lambda_invoke" {
  name        = "${local.name}LambdaInvocation"
  description = "Invoke Lambdas (for CI tests, etc.)"
  policy      = data.aws_iam_policy_document.concourse_lambda_invoke.json
}

resource "aws_iam_role_policy_attachment" "concourse_lambda_invoke" {
  policy_arn = aws_iam_policy.concourse_lambda_invoke.arn
  role       = data.aws_iam_role.worker.id
}
