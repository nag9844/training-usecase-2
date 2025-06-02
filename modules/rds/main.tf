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

  tags = merge(
    var.project_tags,
    {
      Name = "demo-rds"
    }
  )
}

resource "aws_db_instance" "replica-mysql" {
  instance_class       = "db.t3.micro"
  skip_final_snapshot  = true
  backup_retention_period = 7
  replicate_source_db = aws_db_instance.mysql.identifier
  tags = merge(
    var.project_tags,
    {
      Name = "replica-rds"
    }
  )
}