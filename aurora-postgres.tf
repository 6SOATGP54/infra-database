provider "aws" {
  region = "us-east-1"
}

# Verificando se o Cluster RDS já existe
data "aws_rds_cluster" "existing_cluster" {
  cluster_identifier = "aurora-cluster-food"
}

# Verificando se as instâncias RDS já existem
data "aws_rds_cluster_instance" "existing_instances" {
  cluster_identifier = data.aws_rds_cluster.existing_cluster.id
}

# Verificando se o grupo de segurança já existe
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["aurora-sg"]
  }
}

# Verificando se as sub-redes já existem
data "aws_subnet" "existing_subnet_1" {
  filter {
    name   = "cidr"
    values = ["172.31.128.0/20"]
  }
}

data "aws_subnet" "existing_subnet_2" {
  filter {
    name   = "cidr"
    values = ["172.31.144.0/20"]
  }
}

data "aws_subnet" "existing_subnet_3" {
  filter {
    name   = "cidr"
    values = ["172.31.160.0/20"]
  }
}

# Criando o Cluster RDS apenas se ele não existir
resource "aws_rds_cluster" "postgresql" {
  count = data.aws_rds_cluster.existing_cluster ? 0 : 1

  cluster_identifier      = "aurora-cluster-food"
  engine                  = "aurora-postgresql"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "food"
  master_username         = "food"
  master_password         = "mV3&04I}Pt"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group[0].name
}

# Criando as instâncias do RDS apenas se não existirem
resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = (length(data.aws_rds_cluster_instance.existing_instances) > 0) ? 0 : 2
  identifier         = "aurora-cluster-food-instance"
  cluster_identifier = aws_rds_cluster.postgresql[0].id
  instance_class     = "db.r5.large"
  engine             = "aurora-postgresql"
}

# Criando o grupo de segurança apenas se não existir
resource "aws_security_group" "aurora_sg" {
  count = data.aws_security_group.existing_sg ? 0 : 1
  name   = "aurora-sg"

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

# Criando as sub-redes
resource "aws_subnet" "aurora_subnet_1" {
  count = data.aws_subnet.existing_subnet_1 ? 0 : 1
  vpc_id            = "vpc-05ed0e14e65d479e1"
  availability_zone = "us-east-1a"
  cidr_block        = "172.31.128.0/20"
}

resource "aws_subnet" "aurora_subnet_2" {
  count = data.aws_subnet.existing_subnet_2 ? 0 : 1
  vpc_id            = "vpc-05ed0e14e65d479e1"
  availability_zone = "us-east-1b"
  cidr_block        = "172.31.144.0/20"
}

resource "aws_subnet" "aurora_subnet_3" {
  count = data.aws_subnet.existing_subnet_3 ? 0 : 1
  vpc_id            = "vpc-05ed0e14e65d479e1"
  availability_zone = "us-east-1c"
  cidr_block        = "172.31.160.0/20"
}

# Criando o grupo de sub-rede
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [
    aws_subnet.aurora_subnet_1[0].id,
    aws_subnet.aurora_subnet_2[0].id,
    aws_subnet.aurora_subnet_3[0].id
  ]
}
