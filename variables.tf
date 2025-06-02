# Variables for the main Terraform configuration

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use for the subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0e35ddab05955cf57"
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  default     = "mypassword"
}

variable "project_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "web-tier-2"
    Environment = "Development"
    Terraform   = "true"
  }
}