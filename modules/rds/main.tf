resource "aws_db_subnet_group" "rds" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(
    var.project_tags,
    {
      Name = "rds-subnet-groups"
    }
  )
}

resource "aws_db_instance" "mysql" {
  identifier               = "demo-rds"
  allocated_storage        = var.allocated_storage
  engine                   = var.engine
  engine_version           = var.engine_version
  instance_class           = var.instance_class
  db_name                  = var.db_name
  username                 = var.username
  password                 = var.password
  publicly_accessible      = false
  db_subnet_group_name     = aws_db_subnet_group.rds.name
  vpc_security_group_ids   = var.vpc_security_group_ids

  # Required for read replica creation
  backup_retention_period  = 7
  skip_final_snapshot      = false
  final_snapshot_identifier = "db-snap"
  multi_az                 = true
  maintenance_window       = "Mon:00:00-Mon:03:00"
  backup_window            = "03:00-06:00"

  tags = merge(
    var.project_tags,
    {
      Name = "demo-rds"
    }
  )
}

resource "aws_db_instance" "demo-rds-read" {
  identifier              = "demo-rds-read"
  replicate_source_db     = aws_db_instance.mysql.identifier
  instance_class          = "db.t3.micro"
  skip_final_snapshot     = true

  # Not required, but keeps a backup for replica in case of promotion
  backup_retention_period = 1

  tags = merge(
    var.project_tags,
    {
      Name = "replica-rds"
    }
  )

  depends_on = [aws_db_instance.mysql]
}
