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

# Configure the Provider
variable "provider_token" {
  type = string
  sensitive = true
}

# Create Resources
provider "fakewebservices" {
  token = var.provider_token
}

resource "fakewebservices_vpc" "primary_vpc" {
  name       = "Primary VPC"
  cidr_block = "0.0.0.0/1"
}

resource "fakewebservices_server" "servers" {
  count = 2

  name = "Server ${count.index + 1}"
  type = "t2.micro"
  vpc  = fakewebservices_vpc.primary_vpc.name
}

resource "fakewebservices_load_balancer" "primary_lb" {
  name    = "Primary Load Balancer"
  servers = fakewebservices_server.servers[*].name
}

resource "fakewebservices_database" "prod_db" {
  name = "Production DB"
  size = 256
}
