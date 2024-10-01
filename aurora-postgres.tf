provider "aws" {
  region = "us-east-1"
}

# Buscar a VPC dinamicamente pelo nome
data "aws_vpc" "selected_vpc" {
  filter {
    name   = "tag:Name"
    values = ["eks-cluster-vpc"] # Substitua pelo nome da sua VPC
  }
}

# Subnets criadas dinamicamente a partir do bloco CIDR da VPC
resource "aws_subnet" "aurora_subnet_1" {
  vpc_id            = data.aws_vpc.selected_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.176.0/20" # Calcula o bloco CIDR para a subnet 1
}

resource "aws_subnet" "aurora_subnet_2" {
  vpc_id            = data.aws_vpc.selected_vpc.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.208.0/20" # Calcula o bloco CIDR para a subnet 2
}

resource "aws_subnet" "aurora_subnet_3" {
  vpc_id            = data.aws_vpc.selected_vpc.id
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.192.0/20" # Calcula o bloco CIDR para a subnet 3
}

# Grupo de subnets do Aurora RDS
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name = "aurora-subnet-group"
  subnet_ids = [
    aws_subnet.aurora_subnet_1.id,
    aws_subnet.aurora_subnet_2.id,
    aws_subnet.aurora_subnet_3.id
  ]
}

# Cluster Aurora PostgreSQL
resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "aurora-cluster-food"
  engine                  = "aurora-postgresql"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "food"
  master_username         = "food"
  master_password         = "mV3&04I}Pt"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
}

# Instâncias do Aurora PostgreSQL
resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = 2
  identifier         = "aurora-cluster-food-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class     = "db.r5.large"
  engine             = "aurora-postgresql"
}

# Grupo de segurança
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
