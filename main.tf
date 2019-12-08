# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A SINGLE EC2 INSTANCE
# This template runs a simple "Hello, World" web server on a single EC2 Instance
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
  region = "eu-west-2"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "jumpcloud" {
  # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type in us-east-2
  ami                    = "ami-0be057a22c63962cb"
  instance_type          = "t3a.micro"
  vpc_security_group_ids = [aws_security_group.SSH.id, aws_security_group.HTTP.id,]
  key_name = "20191208Key"
  user_data = <<-EOF
              #!/bin/bash
              # Jumpcloud 
              curl --tlsv1.2 --silent --show-error --header 'x-connect-key: e9a25c70a7747270d313f81f186099cba1b91e66' https://kickstart.jumpcloud.com/Kickstart | sudo bash
              # Install Apache Server
              sudo apt install apache2 -y
              cd /var/www/html/
              sudo rm -f index.html 
              sudo touch index.html
              echo "<h1>Hello World</h1>" | sudo tee -a index.html
              cd /
              EOF

  tags = {
    Name = "terraform-ubuntuserver"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "SSH" {
  name = "terraform-SSH"

  # Inbound SSH
  ingress {
    from_port   = var.SSHserver_port
    to_port     = var.SSHserver_port
    protocol    = "tcp"
    cidr_blocks = ["195.206.183.144/32"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "HTTP" {
  name = "terraform-HTTP"

  # Inbound Web
  ingress {
    from_port   = var.Webserver_port
    to_port     = var.Webserver_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}