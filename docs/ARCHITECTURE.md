# System Architecture

## Overview
This document describes the high-level architecture of the Docker Swarm deployment on AWS.

## Components

1. **Infrastructure (AWS)**
   - Provisioned via Terraform
   - 1 Swarm Manager Node (t3.micro)
   - 2 Swarm Worker Nodes (t3.micro)
   - Custom VPC, Subnets, and Security Groups allowing Docker Swarm overlay network traffic.

2. **Configuration Management**
   - Managed via Ansible
   - Automated installation of Docker CE
   - Automated Swarm initialization and worker token exchange

3. **Application Stack**
   - Node.js Backend Application (`app_backend`)
   - MongoDB Database (`app_mongo`)
   - Traefik Reverse Proxy for routing

4. **CI/CD Pipeline (GitHub Actions)**
   - **CI Pipeline**: Triggers on push to `main`. Builds Docker image, authenticates with AWS ECR, and pushes the image.
   - **CD Pipeline**: Triggers on successful CI. Connects via SSH to Swarm Manager, logs into ECR, and executes `docker stack deploy` and `docker service update` for zero-downtime rollouts.

5. **Monitoring Stack**
   - Prometheus for scraping metrics
   - Node Exporter for host metrics
   - Grafana (Optional) for dashboard visualization
