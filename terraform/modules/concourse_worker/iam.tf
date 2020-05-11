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

resource "aws_iam_role_policy_attachment" "concourse_parameters_worker" {
  policy_arn = aws_iam_policy.concourse_parameters_worker.arn
  role       = aws_iam_role.worker.id
}

resource "aws_iam_policy" "concourse_parameters_worker" {
  name        = "${local.name}ParameterStoreAccess"
  description = "Access to SSM for Web Nodes"
  policy      = data.aws_iam_policy_document.concourse_parameters_worker.json
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
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "CiAllowAssumeRoleWorker" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/CiAllowAssumeRole"
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "TerraformDependenciesWorker" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/TerraformDependencies"
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "AllowCiToRunTerraformWorker" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AllowCiToRunTerraform"
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "RemoteStateWriteWorker" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/RemoteStateWrite"
  role       = aws_iam_role.worker.id
}
