packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "tf-gen-code-server"
  instance_type = "t2.micro"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images*ubuntu-*-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "tf-gen-code-server"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo rm -r /var/lib/apt/lists/*",
      "sudo apt-get update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
      "sudo snap install core && sudo snap refresh core",
      "sudo snap install --classic certbot",
      "sudo ln -s /snap/bin/certbot /usr/bin/certbot",
    ]
  }

  provisioner "file" {
    source = "./files/code-server_3.12.0_amd64.deb"
    destination = "/tmp/code-server_3.12.0_amd64.deb"
  }

  provisioner "file" {
    source = "./files/code-server.service"
    destination = "/tmp/code-server.service"
  }

  provisioner "shell" {
    inline = [
      "sudo dpkg -i /tmp/code-server_3.12.0_amd64.deb",
      "sudo cp /tmp/code-server.service /etc/systemd/system/code-server.service",
      "sudo systemctl enable code-server",
      "sudo systemctl start code-server",
    ]
  }

  provisioner "file" {
    source = "./files/nginx-conf"
    destination = "/tmp/nginx-conf"
  }

  provisioner "shell" {
    inline = [
      "sudo cp /tmp/nginx-conf /etc/nginx/sites-available/conf",
      "sudo ln -s /etc/nginx/sites-available/conf /etc/nginx/sites-enabled/conf",
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo service nginx configtest",
      "sudo service nginx restart",
    ]
  }
}
