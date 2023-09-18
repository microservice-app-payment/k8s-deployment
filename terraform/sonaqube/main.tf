terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = "AKIA6APTF3CQMTJUEKVY"
  secret_key = "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"
}

// To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {
  default     = "sonarqube.pem" 
  description = "Sonarqube-Server-Key"
}

// Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

// Save PEM file locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.key_name
}

# Create a security group
resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"
  description = "SG Sonarqube VM"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_instance" {
  ami                    = "ami-0df7a207adb9748c7"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  tags = {
    Name = "Sonarqube-Server"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.rsa_4096.private_key_pem
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./sonarqube.sh"
    destination = "/tmp/sonarqube.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/sonarqube.sh",
      "/tmp/sonarqube.sh"
    ]
  }
}