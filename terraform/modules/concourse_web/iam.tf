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

resource "aws_iam_role_policy" "parameter_store" {
  name   = "${local.name}ParameterStoreAccess"
  role   = aws_iam_role.web.id
  policy = data.aws_iam_policy_document.secrets.json
}

data "aws_iam_policy_document" "secrets" {
  statement {
    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${var.name}*"
    ]
  }
}
