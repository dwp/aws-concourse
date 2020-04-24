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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
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
