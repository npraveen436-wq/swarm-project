cat > terraform/outputs.tf << 'EOF'
output "manager_public_ip" {
  value = aws_instance.manager.public_ip
}

output "manager_private_ip" {
  value = aws_instance.manager.private_ip
}

output "worker_public_ips" {
  value = aws_instance.workers[*].public_ip
}
EOF
