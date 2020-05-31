resource "aws_db_subnet_group" "cluster" {
  subnet_ids = var.vpc.aws_subnets_private[*].id
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier_prefix = "${var.name}-db-"
  engine                    = var.database.engine
  engine_version            = var.database.engine_version
  availability_zones        = local.zone_names
  database_name             = var.name
  master_username           = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["database_user"]
  master_password           = jsondecode(data.aws_secretsmanager_secret_version.dataworks-secrets.secret_binary)["database_password"]
  backup_retention_period   = 14
  preferred_backup_window   = "01:00-03:00"
  apply_immediately         = true
  db_subnet_group_name      = aws_db_subnet_group.cluster.id
  skip_final_snapshot       = false
  vpc_security_group_ids    = [aws_security_group.db.id]
  tags                      = merge(var.tags, { Name = "${var.name}-db" })
}

resource "aws_rds_cluster_instance" "cluster" {
  count              = var.database.count
  identifier_prefix  = "${var.name}-${local.zone_names[count.index]}-"
  engine             = aws_rds_cluster.cluster.engine
  engine_version     = aws_rds_cluster.cluster.engine_version
  availability_zone  = local.zone_names[count.index]
  cluster_identifier = aws_rds_cluster.cluster.id
  instance_class     = var.database.instance_type
  tags               = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
