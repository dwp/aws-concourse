resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "aws-waf-logs-${var.name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.log_role.arn
    prefix     = "waf/${var.name}/"
    bucket_arn = var.log_bucket
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = var.cloudwatch_log_group
      log_stream_name = "S3Delivery"
    }
  }
}

resource "aws_iam_role" "log_role" {
  name = "${var.name}-logs"

  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

resource "aws_iam_policy" "write_waf_logs_s3" {
  name        = "${var.name}_WriteLogs"
  description = "Allow writing WAF logs to S3"
  policy      = data.aws_iam_policy_document.write_s3_logs.json
}

resource "aws_iam_role_policy_attachment" "write_s3_firehose" {
  role       = aws_iam_role.log_role.name
  policy_arn = aws_iam_policy.write_waf_logs_s3.arn
}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "write_s3_logs" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${var.log_bucket}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:PutObject*",
    ]

    resources = [
      "${var.log_bucket}/waf/*"
    ]
  }
}
