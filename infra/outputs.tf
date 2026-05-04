output "swarm_manager_ip" {
  value = aws_instance.swarm_manager[0].public_ip
}

output "swarm_workers_ips" {
  value = aws_instance.swarm_workers[*].public_ip
}

output "swarm_manager_private_ip" {
  value = aws_instance.swarm_manager[0].private_ip
}

output "swarm_workers_private_ips" {
  value = aws_instance.swarm_workers[*].private_ip
}

output "security_group_id" {
  value = aws_security_group.swarm.id
}

output "ecr_backend_uri" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_uri" {
  value = aws_ecr_repository.frontend.repository_url
}
