# Production-Grade CI/CD & Monitoring System (Tier 4)

This repository contains the source code and infrastructure configuration for a production-grade Node.js application deployed on a multi-node Docker Swarm cluster.

## Key Features

- Multi-node Docker Swarm cluster (1 Manager, 2 Workers) for high availability and scheduling.
- Infrastructure as Code (IaC) using Terraform for AWS provisioning and Ansible for configuration.
- Automated CI/CD pipeline via GitHub Actions with integrated security scanning using Trivy.
- Full-stack observability with Prometheus, Grafana, cAdvisor, and Node Exporter.
- Zero-downtime rolling updates and self-healing service capabilities.

## System Architecture

- Infrastructure: 3x AWS EC2 instances (t3.small) deployed within a custom VPC.
- Orchestration: Docker Swarm for service replication and load balancing.
- Reverse Proxy: Traefik with automated Let's Encrypt SSL termination.
- Database: MongoDB with persistent volume storage for data durability.

## Technology Stack

- Cloud Provider: Amazon Web Services (EC2, ECR, VPC)
- Automation: Terraform, Ansible
- Containers: Docker, Docker Swarm
- CI/CD: GitHub Actions, Aqua Security Trivy
- Monitoring: Prometheus, Grafana, cAdvisor, Node Exporter
- Backend: Node.js (Express), MongoDB

## Deployment Instructions

### 1. Provision Infrastructure
Navigate to the `infra` directory and apply the Terraform configuration:
```bash
cd infra
terraform init
terraform apply -var-file="terraform.tfvars"
```

### 2. Configure Cluster
Use Ansible to install Docker and initialize the Swarm cluster:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

### 3. Application Deployment
Push code to the `main` branch to trigger the automated deployment pipeline. The system will build the image, perform a security scan, and deploy the updated stack to the manager node.

## Application Access
- Application: https://orangecaramel.online

## Monitoring Access
- Prometheus: https://prometheus.orangecaramel.online
- Grafana: https://grafana.orangecaramel.online
- Application Health: https://orangecaramel.online/health

## Operational Scripts
Operational tasks can be executed via the provided Makefile or standalone scripts:
- make simulate-failure: Test system self-healing by simulating container failure.
- make rollback: Revert to the previous stable version of the deployment.
- debug.sh: Diagnostic tool for cluster health and network connectivity.