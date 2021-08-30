terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = "> 0.7.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "code_server" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_subnet" "code_server" {
  vpc_id            = aws_vpc.code_server.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_network_interface" "code_server" {
  subnet_id   = aws_subnet.code_server.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface-for_code_server"
  }
}

locals {
  canonical_amis_owner = "099720109477"
}

resource "aws_instance" "code_server" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.code_server.id
    device_index         = 0
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"

    tags = {
      Name = "HelloWorld"
    }
  }

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_eip" "code_server" {
  vpc      = true
  instance = aws_instance.code_server.id
}
