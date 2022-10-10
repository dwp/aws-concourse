module "vpc" {
  source                                   = "dwp/vpc/aws"
  version                                  = "3.0.15"
  vpc_name                                 = "ci-cd"
  region                                   = data.aws_region.current.name
  vpc_cidr_block                           = var.vpc_cidr_block
  interface_vpce_source_security_group_ids = var.vpc_endpoint_source_sg_ids
  interface_vpce_subnet_ids                = aws_subnet.private.*.id
  gateway_vpce_route_table_ids             = aws_route_table.private.*.id

  aws_vpce_services = [
    "application-autoscaling",
    "athena",
    "autoscaling",
    "cloudformation",
    "codecommit",
    "config",
    "dynamodb",
    "ec2",
    "ec2messages",
    "ecr.api",
    "ecr.dkr",
    "ecs",
    "elasticfilesystem",
    "elasticloadbalancing",
    "elasticmapreduce",
    "events",
    "git-codecommit",
    "glue",
    "kms",
    "kinesis-firehose",
    "logs",
    "monitoring",
    "rds",
    "rds-data",
    "s3",
    "secretsmanager",
    "sns",
    "sqs",
    "ssm",
    "ssmmessages",
    "sts"
  ]

  common_tags = merge(var.tags, { Name = var.name })
}
