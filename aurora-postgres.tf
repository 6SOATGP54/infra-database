resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = ["us-east-1a","us-east-1b","us-east-1c"]
  database_name           = "food"
  master_username         = "food"
  master_password         = "mV+3&04I/}Pt"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}
