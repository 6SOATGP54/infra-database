variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"  # Substitua pela região que você deseja usar
}
provider "aws" {
  region  = "us-east-1"
}
resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "food"
  master_username         = "food"
  master_password         = "mV3&04I}Pt"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = 1
  identifier         = "aurora-instance-demo"
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class     = "db.r5.large"
  engine             = "aurora-postgresql"
}

resource "aws_security_group" "aurora_sg" {
  name = "aurora-sg"

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
}

resource "aws_subnet" "aurora_subnet_1" {
  vpc_id            = "vpc-05ed0e14e65d479e1"  # Substitua pelo seu VPC ID
  availability_zone = "us-east-1a"
  cidr_block        = "172.31.48.0/20"
}

resource "aws_subnet" "aurora_subnet_2" {
  vpc_id            = "vpc-05ed0e14e65d479e1"
  availability_zone = "us-east-1b"
  cidr_block        = "172.31.64.0/20"
}

resource "aws_subnet" "aurora_subnet_3" {
  vpc_id            = "vpc-05ed0e14e65d479e1"
  availability_zone = "us-east-1c"
  cidr_block        = "172.31.80.0/20"
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [
    aws_subnet.aurora_subnet_1.id,
    aws_subnet.aurora_subnet_2.id,
    aws_subnet.aurora_subnet_3.id
  ]
}
