variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  default     = "finaldevops"
}

variable "environment" {
  description = "Environment"
  default     = "production"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium"
}

variable "swarm_manager_count" {
  description = "Number of manager nodes"
  default     = 1
}

variable "swarm_worker_count" {
  description = "Number of worker nodes"
  default     = 2
}

variable "domain_name" {
  description = "Domain name"
  default     = "yourdomain.com"
}

variable "ssh_key_name" {
  description = "AWS SSH Key Pair Name"
  default     = "vockey"
}
