## subnet-group
resource "aws_db_subnet_group" "subnetg-default" {
  name        = "rds-subnetg-${var.project}-${var.env}"
  subnet_ids  = toset(data.aws_subnets.private)
  tags = {
    Name = "rds-subnetg-${var.project}-${var.env}"
  }
}

## parameter-group
resource "aws_rds_cluster_parameter_group" "pgroupdefault" {
  name   = "rds${var.project}${var.env}pgroup"
  family = "aurora-postgresql11"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

## security-group
resource "aws_security_group" "sg-default" {
  name   = "rds-sg-${var.project}-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-${var.project}-${var.env}"
  }
}

## Password 
resource "random_password" "db_master_pwd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

## Cluster PostgreSql
resource "aws_rds_cluster" "db_cluster_1" {
  cluster_identifier = "cluster${var.project}${var.env}"
  engine             = "aurora-postgresql"
  engine_mode        = "serverless"
  engine_version     = "11.16"
  database_name      = "db${var.project}${var.env}"
  storage_encrypted  = true
  skip_final_snapshot    = true

  master_username    = var.username
  master_password    = random_password.db_master_pwd.result

  vpc_security_group_ids = [aws_security_group.sg-default.id]
  db_subnet_group_name   = aws_db_subnet_group.subnetg-default.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.pgroupdefault.name

  scaling_configuration {
    auto_pause               = true
    min_capacity             = 1
    max_capacity             = 4
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  depends_on = [
    aws_security_group.sg-default,
    aws_db_subnet_group.subnetg-default,
    aws_rds_cluster_parameter_group.pgroupdefault,
  ]
  
}