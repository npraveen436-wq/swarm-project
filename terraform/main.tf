terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "pravallika-swarm-tfstate-2026"   # <-- CHANGE THIS
    key    = "swarm/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# Latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_key_pair" "swarm_key" {
  key_name   = "swarm-key"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "swarm_sg" {
  name        = "swarm-sg"
  description = "Allow SSH, HTTP, app port, and Swarm internal traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Swarm internal - between nodes only
  ingress {
    description = "Swarm cluster mgmt"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Swarm node communication TCP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Swarm node communication UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Swarm overlay network"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "manager" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.swarm_key.key_name
  vpc_security_group_ids = [aws_security_group.swarm_sg.id]
  user_data              = file("${path.module}/user_data.sh")

  tags = {
    Name = "swarm-manager"
    Role = "manager"
  }
}

resource "aws_instance" "workers" {
  count                  = 2
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.swarm_key.key_name
  vpc_security_group_ids = [aws_security_group.swarm_sg.id]
  user_data              = file("${path.module}/user_data.sh")

  tags = {
    Name = "swarm-worker-${count.index + 1}"
    Role = "worker"
  }
}
