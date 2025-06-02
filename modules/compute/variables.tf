variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
}

variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "user_data" {
  description = "User data script"
  type        = string
}

variable "project_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}