terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58"
    }
  }
  required_version = "> 0.7.0"
}

provider "aws" {
  region = "us-east-2"
}

locals {
  id   = "terraform_created_code_server"
  name = "[TERRAFORM-CREATED] Code Server"
}

resource "aws_vpc" "code_server" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = local.name
  }
}

resource "aws_internet_gateway" "code_server" {
  vpc_id = aws_vpc.code_server.id

  tags = {
    Name = local.name
  }
}

resource "aws_default_route_table" "code_server" {
  default_route_table_id = aws_vpc.code_server.default_route_table_id
  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.code_server.id
      carrier_gateway_id         = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
      destination_prefix_list_id = ""
      ipv6_cidr_block            = ""
    },
  ]
  tags = {
    Name = local.name
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  filename          = "./code-server.pem"
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0400"

}

resource "aws_key_pair" "code_server" {
  key_name   = "code_server"
  public_key = tls_private_key.key.public_key_openssh
  tags = {
    Name = local.name
  }
}

resource "aws_subnet" "code_server" {
  vpc_id                  = aws_vpc.code_server.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = local.name
  }
}

locals {
  canonical_amis_owner = "099720109477"
}

data "aws_ami" "code_server" {
  owners = ["self"]
  filter {
    name   = "name"
    values = ["tf-gen-code-server"]
  }
}

resource "aws_instance" "code_server" {
  ami                         = data.aws_ami.code_server.image_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.code_server.id
  key_name                    = aws_key_pair.code_server.key_name
  security_groups             = [aws_security_group.code_server.id]
  vpc_security_group_ids      = [aws_security_group.code_server.id]
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    tags = {
      Name = local.name
    }
  }
  provisioner "remote-exec" {
    inline = [
      "cat ~/.config/code-server/config.yaml",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = local_file.private_key.sensitive_content
      host        = self.public_ip
    }
  }
  tags = {
    Name = local.name
  }
}

resource "aws_security_group" "code_server" {
  vpc_id = aws_vpc.code_server.id
  ingress = [
    {
      protocol         = "tcp"
      self             = true
      from_port        = 0
      to_port          = 65535
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Allow TLS inbound traffic"
      security_groups  = []
      prefix_list_ids  = []
    }
  ]
  egress = [
    {
      from_port        = 0
      to_port          = 65535
      protocol         = "tcp"
      self             = true
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Allow TLS inbound traffic"
      security_groups  = []
      prefix_list_ids  = []
    }
  ]
  tags = {
    Name = local.name
  }
}

# resource "aws_route53_zone" "code_server" {
#   name = "code.tanayseven.com"
#   tags = {
#     Name = local.id
#   }
# }

# resource "aws_route53_record" "code_server_a" {
#   zone_id = aws_route53_zone.code_server.zone_id
#   name    = "code.tanayseven.com"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.code_server.public_ip]
# }

output "code_server_ip_address" {
  value = aws_instance.code_server.public_ip
}
