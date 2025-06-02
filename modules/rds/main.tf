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
  identifier           = "demo-rds"
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot  = true
  # Backups are required in order to create a replica
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 1

  tags = merge(
    var.project_tags,
    {
      Name = "demo-rds"
    }
  )
}


resource "aws_db_instance" "replica-mysql" {
  instance_class          = "db.t3.micro"
  skip_final_snapshot     = true
  replicate_source_db     = aws_db_instance.mysql.identifier

  tags = merge(
    var.project_tags,
    {
      Name = "replica-rds"
    }
  )

  depends_on = [aws_db_instance.mysql]  
}



resource "aws_db_instance" "demo-rds-read" {
  identifier             = "demo-rds-read"
  replicate_source_db    = aws_db_instance.mysql.identifier
  instance_class         = "db.t3.micro"
  skip_final_snapshot    = true
# Username and password must not be set for replicas
  username = ""
  password = ""
# disable backups to create DB faster
  backup_retention_period = 0
}