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
  id   = "tf_gen_code_server"
  name = "[TF-GEN] Code Server"
}

resource "aws_vpc" "code_server" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = local.name
  }
}

resource "aws_subnet" "code_server" {
  vpc_id            = aws_vpc.code_server.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = local.name
  }
}

locals {
  canonical_amis_owner = "099720109477"
}

resource "aws_key_pair" "code_server" {
  key_name   = "code_server"
  public_key = file("~/.ssh/code_server.pub")
  tags = {
    Name = local.name
  }
}

resource "aws_instance" "code_server" {
  ami                         = "ami-09e67e426f25ce0d7"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.code_server.id
  key_name                    = aws_key_pair.code_server.key_name
  security_groups             = [aws_security_group.code_server.id]
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    tags = {
      Name = local.name
    }
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/code_server")
    host        = self.public_ip
    timeout     = "2m"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install nginx",
      "sudo service nginx start",
    ]
  }
  tags = {
    Name = local.name
  }
}

resource "aws_security_group" "code_server" {
  name        = local.name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.code_server.id
  # ingress {
  #   description      = "TLS from VPC"
  #   from_port        = 443
  #   to_port          = 443
  #   protocol         = "tcp"
  # }
  ingress {
    description      = "SSH"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    # cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    # cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = local.name
  }
}

resource "aws_route53_zone" "code_server" {
  name = "code.tanayseven.com"
  tags = {
    Name = local.id
  }
}

resource "aws_route53_record" "code_server_a" {
  zone_id = aws_route53_zone.code_server.zone_id
  name    = "code.tanayseven.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.code_server.public_ip]
}
