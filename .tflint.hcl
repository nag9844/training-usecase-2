plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Configure AWS provider version constraints
rule "terraform_required_providers" {
  enabled = true
}

# Naming conventions
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}


# AWS specific rules
rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Environment", "Project", "Terraform"]
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_db_instance_invalid_type" {
  enabled = true
}

#rule "aws_db_instance_encrypted" {
#  enabled = true
#}





