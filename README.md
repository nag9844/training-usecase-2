# AWS 2-Tier Architecture with Terraform

This project implements a highly available 2-tier architecture on AWS using Terraform as Infrastructure as Code (IaC). The architecture consists of a Web tier with EC2 instances behind an Application Load Balancer in public subnets and a Database tier with RDS MySQL in private subnets.


## Architecture Overview

```
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  AWS Cloud (Region)                                                   │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ VPC                                                             │  │
│  │  ┌────────────────┐          ┌────────────────┐                 │  │
│  │  │                │          │                │                 │  │
│  │  │   AZ-1         │          │   AZ-2         │                 │  │
│  │  │  ┌──────────┐  │          │  ┌──────────┐  │                 │  │
│  │  │  │ Public   │  │          │  │ Public   │  │                 │  │
│  │  │  │ Subnet 1 │◄─┼──────────┼─►│ Subnet 2 │  │                 │  │
│  │  │  │          │  │          │  │          │  │  Internet       │  │
│  │  │  │    ALB   │◄─┼──────────┼─►│   ALB    │◄─┼─────Gateway──── ┼──┼─▶ Internet
│  │  │  │          │  │          │  │          │  │                 │  │
│  │  │  │          │  │          │  │          │  │                 │  │
│  │  │  │    ▲     │  │          │  │    ▲     │  │                 │  │
│  │  │  │    │     │  │          │  │    │     │  │                 │  │
│  │  │  │    ▼     │  │          │  │    ▼     │  │                 │  │
│  │  │  │          │  │          │  │          │  │                 │  │
│  │  │  │   EC2    │  │          │  │   EC2    │  │                 │  │
│  │  │  │   Web    │  │          │  │   Web    │  │                 │  │
│  │  │  │  Server  │  │          │  │  Server  │  │                 │  │
│  │  │  └─────┬────┘  │          │  └─────┬────┘  │                 │  │
│  │  │        │       │          │        │       │                 │  │
│  │  │        │       │          │        │       │                 │  │
│  │  │        ▼       │          │        ▼       │                 │  │
│  │  │  ┌──────────┐  │          │  ┌──────────┐  │                 │  │
│  │  │  │ Private  │  │          │  │ Private  │  │                 │  │
│  │  │  │ Subnet 1 │◄─┼──────────┼─►│ Subnet 2 │  │                 │  │
│  │  │  │          │  │          │  │          │  │                 │  │
│  │  │  │ RDS      │◄─┼──────────┼─►│ RDS      │  │                 │  │
│  │  │  │ MySQL    │  │          │  │ MySQL    │  │                 │  │
│  │  │  │ (Primary)│  │          │  │ (Replica)│  │                 │  │
│  │  │  └──────────┘  │          │  └──────────┘  │                 │  │
│  │  │                │          │                │                 │  │
│  │  └────────────────┘          └────────────────┘                 │  │
│  │                                                                 │  │
│  │                                                                 │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```


## Technology Stack

- **Infrastructure as Code**: Terraform
- **Cloud Provider**: AWS
- **Web Servers**: EC2 instances with Apache/Nginx
- **Database**: RDS MySQL
- **CI/CD**: GitHub Actions
- **State Management**: AWS S3, DynamoDB
- **Static Analysis**: TFLint

## Prerequisites

1. AWS Account with appropriate permissions
2. Terraform (v1.10.0+)
3. AWS configuration with Access key or OIDC role arn
4. GitHub repository for version control and CI/CD

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── web-tier-ci-cd.yml
├── modules/
│   ├── VPC/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── load_balancer/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── Security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── rds/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── providers.tf
└── README.md
```

## Implementation Details

### 1. VPC and Networking Setup

The networking module creates:
- Custom VPC
- 2 Public subnets across different AZs
- 2 Private subnets across different AZs
- Internet Gateway
- NAT Gateway for private subnet internet access
- Route tables for both public and private subnets

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_tags         = var.project_tags
}
```

### 2. Web Tier Implementation

The web tier module creates:
- EC2 instances in public subnets
- Security groups allowing HTTP/HTTPS inbound
- Auto Scaling Group for high availability
- Launch template with user data to install web server

```hcl
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
                      EOF
  project_tags = var.project_tags
}
```

### 3. Database Tier Implementation

The database tier module creates:
- RDS MySQL instance in private subnets
- Multi-AZ deployment for high availability
- Security groups allowing access only from web tier

```hcl
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
```

### 4. Remote State Management

The backend configuration uses S3 for state storage and DynamoDB for state locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-name"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
```

## GitHub Actions Workflow

The CI/CD pipeline is configured in `.github/workflows/web-rds.yml`:


## How to Use

1. Clone this repository:
   ```
   git clone https://github.com/your-username/training-usecase-2.git
   cd training-usecase-2
   ```

2. Create a `terraform.tfvars` file with your specific configuration values:
   ```
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. Initialize Terraform:
   ```
   terraform init
   ```

4. Plan the deployment:
   ```
   terraform plan
   ```

5. Apply the configuration:
   ```
   terraform apply
   ```

6. To destroy the infrastructure:
   ```
   terraform destroy
   ```

## Security Considerations

- EC2 instances in public subnets have security groups restricting access to HTTP/HTTPS and SSH from specific IPs
- RDS instances in private subnets are only accessible from the web tier
- All data in transit is encrypted
- Remote state is encrypted in S3



