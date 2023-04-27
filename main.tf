terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIA5JPR35OHWVHBXD73"
  secret_key = "nhTTDzcf/sj1dY1yZo7BqUzZt7YE57JdU0CMs/pe"
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


# Create ElasticSearch Domain
resource "aws_elasticsearch_domain" "example" {
  domain_name           = "example"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type = "r4.large.elasticsearch"
  }

  advanced_security_options {
    enabled = true
  }
  
  domain_endpoint_options {
    enforce_https = true
  }

  tags = {
    Domain = "TestDomain"
  }
}

# Create Lambda Function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs16.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}


# Create Launch Configuration
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "as_conf" {
  name          = "web_config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}
