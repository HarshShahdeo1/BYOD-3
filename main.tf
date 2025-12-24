terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# -----------------------------
# AWS Provider
# -----------------------------
provider "aws" {
  region = var.aws_region
}

# -----------------------------
# Security Group for Splunk EC2
# -----------------------------
resource "aws_security_group" "splunk_sg" {
  name        = "byod3-splunk-sg"
  description = "Allow SSH and Splunk Web (8000)"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Splunk Web UI"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BYOD3-Splunk-SG"
  }
}

# -----------------------------
# EC2 Instance for Splunk
# -----------------------------
resource "aws_instance" "splunk_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]

  tags = {
    Name        = "BYOD3-Splunk-Instance"
    Environment = "Dev"
  }
}
