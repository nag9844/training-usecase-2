resource "aws_db_subnet_group" "rds" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(
    var.project_tags,
    {
      Name = "public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}

resource "aws_db_instance" "mysql" {
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
      Name = "public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}

