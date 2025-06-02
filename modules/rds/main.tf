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

resource "aws_kms_key" "default" {
  description = "Encryption key for automated backups"

}

resource "aws_db_instance_automated_backups_replication" "default" {
  source_db_instance_arn = aws_db_instance.mysql.arn
  kms_key_id             = aws_kms_key.default.arn

}