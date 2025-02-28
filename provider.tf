# provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

# Specify the provider and access details
provider "aws" {
    region     = var.aws_region
}