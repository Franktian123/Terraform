terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#Integrate with Terraform Cloud
terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "example-org-041d90"

    workspaces {
      name = "getting-started"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}


# Create variable
variable "ami_id" {
  default = "ami-2e1ef954"
}

variable "instance_type" {
  default = "t2.micro"
}

# Create a instance
resource "aws_instance" "ubuntu" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"

  tags = {
    Name = "HelloWorld"
  }
}
