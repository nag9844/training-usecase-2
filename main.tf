terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.10.0"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_tags         = var.project_tags
}

module "security" {
  source = "./modules/security"
  
  vpc_id       = module.vpc.vpc_id
  project_tags = var.project_tags
}

module "compute" {
  source            = "./modules/compute"
  instance_count    = 2
  ami               = var.ami
  instance_type     = var.instance_type
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security.web_security_group_id
  user_data         = <<-EOF
                      #!/bin/bash
                      sudo apt update -y
                      sudo apt install -y nginx 
                      sudo systemctl start nginx
                      sudo systemctl enable nginx
                      HOSTNAME=$(hostname)
                      echo '<html><body><h1>Hostname: '"$HOSTNAME"'</h1></body></html>' > /usr/share/nginx/html/index.html
                      sudo systemctl restart nginx
                      EOF
  project_tags = var.project_tags
}


module "rds" {
  source               = "./modules/rds"
  db_subnet_group_name = "main-db-subnet-group"
  subnet_ids           = module.vpc.private_subnet_ids
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [module.security.rds_security_group_id]
  project_tags            = var.project_tags
}

module "load_balancer" {
  source                = "./modules/load_balancer"
  name                  = "web-lb"
  security_group_id     = module.security.web_security_group_id
  subnet_ids            = module.vpc.public_subnet_ids
  target_group_name     = "web-target-group"
  target_group_port     = 80
  target_group_protocol = "HTTP"
  vpc_id                = module.vpc.vpc_id
  health_check_path     = "/"
  health_check_protocol = "HTTP"
  health_check_interval = 30
  health_check_timeout  = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 2
  listener_port         = 80
  listener_protocol     = "HTTP"
  target_ids            = module.compute.web_instance_ids
  project_tags            = var.project_tags
}