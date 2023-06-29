data "local_file" "concourse_config_hcs_script" {
  filename = "${path.module}/templates/config_hcs.sh"
}

resource "aws_s3_object" "concourse_config_hcs_script" {
  bucket     = var.config_bucket_id
  key        = "component/concourse/config_hcs.sh"
  content    = data.local_file.concourse_config_hcs_script.content
  kms_key_id = var.config_bucket_cmk_arn
}