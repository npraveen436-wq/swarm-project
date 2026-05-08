variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.small"   # 2GB RAM minimum for swarm
}

variable "ssh_public_key" {
  description = "Public SSH key contents (passed in via -var)"
  type        = string
}
