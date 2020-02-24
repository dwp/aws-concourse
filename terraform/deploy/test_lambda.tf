data "aws_iam_role" "packer_egress_test" {
  name = "packer_egress_test"
}

resource "aws_lambda_function" "concourse_egress_test" {
  filename         = "${var.packer_egress_test_zip["base_path"]}/packer-egress-test-${var.packer_egress_test_zip["version"]}.zip"
  source_code_hash = filebase64sha256(format("%s/packer-egress-test-%s.zip", var.packer_egress_test_zip["base_path"], var.packer_egress_test_zip["version"]))
  function_name    = "concourse_egress_test"
  handler          = "main.handler"
  role             = data.aws_iam_role.packer_egress_test.arn
  runtime          = "python3.7"
  timeout          = 600

  vpc_config {
    subnet_ids         = module.vpc.outputs.aws_subnets_private.*.id
    security_group_ids = [module.concourse_worker.outputs.security_group.id]
  }

  environment {
    variables = {
      LOG_LEVEL   = "INFO"
      HTTP_PROXY  = data.terraform_remote_state.internet_egress.outputs.internet_proxy.http_address
      HTTPS_PROXY = data.terraform_remote_state.internet_egress.outputs.internet_proxy.https_address
      NO_PROXY    = var.concourse_no_proxy
      http_proxy  = data.terraform_remote_state.internet_egress.outputs.internet_proxy.http_address
      https_proxy = data.terraform_remote_state.internet_egress.outputs.internet_proxy.https_address
      no_proxy    = var.concourse_no_proxy
    }
  }

  tags = merge(
    local.tags,
    map("Name", "concourse_egress_test"),
    map("contains-sensitive-info", "False")
  )

  depends_on = [aws_cloudwatch_log_group.concourse_egress_test]
}

resource "aws_cloudwatch_log_group" "concourse_egress_test" {
  name              = "/aws/lambda/concourse_egress_test"
  retention_in_days = 30
}
