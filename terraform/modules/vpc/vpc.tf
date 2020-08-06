module "vpc" {
  source                                   = "dwp/vpc/aws"
  version                                  = "3.0.5"
  vpc_name                                 = "ci-cd"
  region                                   = data.aws_region.current.name
  vpc_cidr_block                           = var.vpc_cidr_block
  interface_vpce_source_security_group_ids = var.vpc_endpoint_source_sg_ids
  interface_vpce_subnet_ids                = aws_subnet.private.*.id
  gateway_vpce_route_table_ids             = aws_route_table.private.*.id

  aws_vpce_services = [
    "ec2autoscaling",
    "ec2",
    "ec2messages",
    "kms",
    "logs",
    "monitoring",
    "s3",
    "ssm",
    "ssmmessages",
    "secretsmanager",
    "ecrapi",
    "ecr.dkr",
    "ecs",
    "elasticloadbalancing",
    "events",
    "application_autoscaling",
    "kinesis_firehose",
    "glue",
    "emr",
    "dynamodb",
    "efs",
    "sns",
    "athena"
  ]
  common_tags = merge(var.tags, { Name = var.name })
}
