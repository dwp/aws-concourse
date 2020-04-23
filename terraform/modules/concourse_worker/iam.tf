resource "aws_iam_role" "worker" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.worker.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "worker" {
  name = aws_iam_role.worker.name
  role = aws_iam_role.worker.id
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

resource "aws_iam_role_policy_attachment" "ci_user" {
  policy_arn = var.concourse_web.ci_user_arn
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "remote_state_read_policy" {
  policy_arn = var.concourse_web.remote_state_read_policy_arn
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "terraform_dependencies" {
  policy_arn = var.concourse_web.terraform_dependencies_arn
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "remote_state_write_policy" {
  policy_arn = var.concourse_web.remote_state_write_policy_arn
  role       = aws_iam_role.worker.id
}

resource "aws_iam_role_policy_attachment" "ci_user_policy" {
  policy_arn = var.concourse_web.ci_user_policy_arn
  role       = aws_iam_role.worker.id
}
