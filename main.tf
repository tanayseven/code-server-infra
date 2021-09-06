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

locals {
  id   = "code_server"
  name = "[TF-GEN] Code Server"
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

locals {
  canonical_amis_owner = "099720109477"
}

resource "aws_key_pair" "code_server" {
  key_name   = "code_server"
  public_key = file("~/.ssh/code_server.pub")
}

resource "aws_instance" "code_server" {
  ami                         = "ami-09e67e426f25ce0d7"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.code_server.id
  key_name                    = aws_key_pair.code_server.key_name

  root_block_device {
    volume_size = 8
    volume_type = "gp3"

    tags = {
      Name = "HelloWorld"
    }
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/code_server")
    host        = self.public_ip
    timeout     = 30
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install ",
    ]
  }

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_route53_zone" "code_server" {
  name = "code.tanayseven.com"
  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_route53_record" "code_server_a" {
  zone_id = aws_route53_zone.code_server.zone_id
  name    = "code.tanayseven.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.code_server.public_ip]
}

