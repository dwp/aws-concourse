resource "aws_iam_role" "worker" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.worker.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "worker" {
  name = aws_iam_role.worker.name
  role = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logging" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.worker.id
}

data "aws_iam_policy_document" "worker" {
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

resource "aws_iam_role_policy_attachment" "CiAllowAssumeRole" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/CiAllowAssumeRole"
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "AllowCiToRunTerraform" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AllowCiToRunTerraform"
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "TerraformDependencies" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/TerraformDependencies"
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "AllowCiToRunTerraform" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AllowCiToRunTerraform"
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "RemoteStateWrite" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/RemoteStateWrite"
  role       = aws_iam_role.worker.id
}
