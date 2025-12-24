terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------
# 1. Generate a New SSH Key Pair
# -----------------------------
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = var.key_name   # This uses the name from your variable (e.g. byod3-key)
  public_key = tls_private_key.pk.public_key_openssh
}

# -----------------------------
# 2. Save the Private Key to a File (For Ansible)
# -----------------------------
resource "local_file" "ssh_key" {
  filename = "${path.module}/${var.key_name}.pem"
  content  = tls_private_key.pk.private_key_pem
  file_permission = "0400"  # Sets correct permission automatically
}

# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "splunk_sg" {
  name        = "byod3-splunk-sg-v2" # Changed name to avoid "Already Exists" error
  description = "Allow SSH and Splunk Web"

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
# EC2 Instance
# -----------------------------
resource "aws_instance" "splunk_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  
  # IMPORTANT: Use the key we just created above
  key_name               = aws_key_pair.kp.key_name
  
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]

  tags = {
    Name        = "BYOD3-Splunk-Instance"
    Environment = "Dev"
  }
  
  # Ensure the key is created before the instance
  depends_on = [ local_file.ssh_key ]
}