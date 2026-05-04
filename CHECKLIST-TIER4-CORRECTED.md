# ✅ FINAL DEVOPS CHECKLIST – TIER 4 (DOCKER SWARM + AWS)
**Status**: Ready to Implement  
**Cloud**: AWS Learner Lab  
**Architecture**: Docker Swarm (1 Manager + 2 Workers)  
**Domain**: HTTPS với Let's Encrypt

--- uyenn

## 📌 PHẦN 0: PREREQUISITE & SETUP

### 0.1 AWS Account & Credentials
- [ ] AWS Learner Lab access active
- [ ] AWS CLI configured locally (`aws configure`)
- [ ] AWS credentials exported as env vars
- [ ] Region set (e.g., `us-east-1`)
- [ ] Budget monitoring enabled

### 0.2 GitHub Setup
- [ ] GitHub repo created & cloned
- [ ] GitHub Secrets configured:
  - [ ] `AWS_ACCESS_KEY_ID`
  - [ ] `AWS_SECRET_ACCESS_KEY`
  - [ ] `AWS_REGION`
  - [ ] `ECR_REGISTRY_BACKEND`
  - [ ] `ECR_REGISTRY_FRONTEND`
  - [ ] `DOMAIN_NAME`
  - [ ] `SSH_PRIVATE_KEY` (for Swarm Manager)
  - [ ] `SSH_KEY_NAME` (EC2 key pair name)

### 0.3 Local Tools
- [ ] Terraform installed (`terraform --version`)
- [ ] Ansible installed (`ansible --version`)
- [ ] AWS CLI installed
- [ ] Docker Desktop running (for local testing)
- [ ] VS Code + Extensions ready

### 0.4 Domain & DNS
- [ ] Domain registered (Route53, GoDaddy, etc.)
- [ ] DNS A record created (will point to Load Balancer/EC2 after Terraform)
- [ ] Note domain name for use in configs

---

## 🔧 PHẦN 1: INFRASTRUCTURE AS CODE (TERRAFORM)

### 1.1 Project Structure
```
infra/
├── main.tf              ← AWS provider, state backend
├── variables.tf         ← All input variables
├── outputs.tf          ← Output IPs, security group IDs
├── swarm.tf            ← EC2 instances (manager + workers)
├── networking.tf       ← VPC, subnets, route tables, IGW
├── security.tf         ← Security Groups + rules
├── ecr.tf              ← ECR repositories
├── terraform.tfvars    ← Variable values (git-ignored)
└── .gitignore          ← Ignore .tfstate, .tfvars
```

### 1.2 main.tf - AWS Provider & Backend State
- [ ] Define AWS provider (region: us-east-1)
- [ ] Configure S3 backend for state (optional but recommended)
- [ ] Add DynamoDB for state locking (optional)
- [ ] Include required_providers block
- [ ] Add terraform block with version constraint

### 1.3 variables.tf - Input Variables
- [ ] `aws_region` (default: us-east-1)
- [ ] `project_name` (e.g., "finaldevops")
- [ ] `environment` (dev/staging/prod)
- [ ] `vpc_cidr` (e.g., "10.0.0.0/16")
- [ ] `instance_type` (e.g., "t2.medium" for Learner Lab)
- [ ] `swarm_manager_count` (default: 1)
- [ ] `swarm_worker_count` (default: 2)
- [ ] `domain_name` (e.g., "example.com")
- [ ] `container_registry_backend` (for ECR URI)
- [ ] `container_registry_frontend`

### 1.4 networking.tf - VPC & Network Setup (Simplified for Learner Lab)
- [ ] Create VPC with `vpc_cidr` (10.0.0.0/16)
- [ ] Create 1 public subnet:
  - [ ] Subnet: 10.0.1.0/24 (all nodes here)
- [ ] Create Internet Gateway (IGW)
- [ ] Create route table with IGW route (0.0.0.0/0 → IGW)
- [ ] Associate subnet with route table
- [ ] Output subnet ID for swarm.tf

### 1.5 security.tf - Security Groups
- [ ] Create security group for Swarm nodes
- [ ] Inbound rules:
  - [ ] SSH (22) from your IP or 0.0.0.0/0
  - [ ] HTTP (80) from 0.0.0.0/0
  - [ ] HTTPS (443) from 0.0.0.0/0
  - [ ] Docker Swarm manager port (2377) from Security Group itself
  - [ ] Docker Swarm overlay network (4789/UDP) from Security Group itself
  - [ ] Docker Swarm gossip (7946/TCP+UDP) from Security Group itself
  - [ ] Application ports (e.g., 3000 for backend) from 0.0.0.0/0
- [ ] Outbound rules:
  - [ ] All traffic to 0.0.0.0/0
- [ ] Output security group ID

### 1.6 swarm.tf - EC2 Instances
- [ ] Create EC2 key pair (or reference existing)
- [ ] Create 1 Manager instance:
  - [ ] AMI: Ubuntu 22.04 LTS
  - [ ] Instance type: t2.medium
  - [ ] Subnet: Public subnet (10.0.1.0/24)
  - [ ] Public IP: Enabled
  - [ ] Security Group: Swarm SG
  - [ ] Tags: Name=swarm-manager, Role=manager
  - [ ] User data: Empty (will use Ansible)
- [ ] Create 2 Worker instances:
  - [ ] AMI: Ubuntu 22.04 LTS
  - [ ] Instance type: t2.medium each
  - [ ] Subnet: Same public subnet
  - [ ] Public IPs: Enabled
  - [ ] Security Group: Swarm SG
  - [ ] Tags: Name=swarm-worker-{1,2}, Role=worker
  - [ ] User data: Empty (will use Ansible)
- [ ] Output manager public IP
- [ ] Output worker public IPs
- [ ] Output private IPs for all nodes

### 1.7 ecr.tf - Elastic Container Registry
- [ ] Create ECR repository for backend
  - [ ] Name: "finaldevops/backend"
  - [ ] Image tag mutability: IMMUTABLE
  - [ ] Scan on push: ENABLED
- [ ] Create ECR repository for frontend
  - [ ] Name: "finaldevops/frontend"
  - [ ] Image tag mutability: IMMUTABLE
  - [ ] Scan on push: ENABLED
- [ ] Output ECR URIs for CI/CD pipeline

### 1.8 outputs.tf - Export Values
```hcl
output "swarm_manager_ip" {
  value = aws_instance.swarm_manager.public_ip
}
output "swarm_workers_ips" {
  value = aws_instance.swarm_workers[*].public_ip
}
output "swarm_manager_private_ip" {
  value = aws_instance.swarm_manager.private_ip
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
```

### 1.9 terraform.tfvars - Variable Values
```hcl
aws_region              = "us-east-1"
project_name            = "finaldevops"
environment             = "production"
vpc_cidr                = "10.0.0.0/16"
instance_type           = "t2.medium"
swarm_manager_count     = 1
swarm_worker_count      = 2
domain_name             = "yourdomain.com"
```

### 1.10 Terraform Validation & Deployment
- [ ] Run `terraform init`
- [ ] Run `terraform validate`
- [ ] Run `terraform fmt` (format)
- [ ] Run `terraform plan` → Review outputs
- [ ] Run `terraform apply` → Confirm
- [ ] Verify EC2 instances created in AWS Console
- [ ] Save Terraform outputs to file: `terraform output > outputs.json`
- [ ] Create `terraform.tfstate.backup` before next steps

---

## 🎯 PHẦN 2: CONFIGURATION MANAGEMENT (ANSIBLE)

### 2.1 Project Structure
```
ansible/
├── ansible.cfg           ← Ansible configuration
├── inventory.ini         ← Host inventory (EC2 IPs)
├── playbook.yml          ← Main playbook orchestrator
├── roles/
│   ├── common/           ← System packages, users
│   │   └── tasks/main.yml
│   ├── docker/           ← Docker CE installation
│   │   └── tasks/main.yml
│   ├── swarm-manager/    ← Initialize Swarm manager
│   │   └── tasks/main.yml
│   ├── swarm-worker/     ← Join workers to Swarm
│   │   └── tasks/main.yml
│   ├── reverse-proxy/    ← Traefik or Nginx
│   │   ├── tasks/main.yml
│   │   └── templates/    ← config files
│   ├── ssl-cert/         ← Let's Encrypt setup
│   │   └── tasks/main.yml
│   └── monitoring/       ← Prometheus, Node Exporter
│       ├── tasks/main.yml
│       └── templates/    ← config files
└── group_vars/
    ├── all.yml           ← Common variables
    ├── managers.yml      ← Manager-specific vars
    └── workers.yml       ← Worker-specific vars
```

### 2.2 ansible.cfg - Configuration
```ini
[defaults]
host_key_checking = False
inventory = inventory.ini
remote_user = ubuntu
private_key_file = ~/.ssh/your-key.pem
```

### 2.3 inventory.ini - Inventory
```ini
[managers]
manager-1 ansible_host=<MANAGER_PUBLIC_IP> ansible_user=ubuntu

[workers]
worker-1 ansible_host=<WORKER1_PUBLIC_IP> ansible_user=ubuntu
worker-2 ansible_host=<WORKER2_PUBLIC_IP> ansible_user=ubuntu

[swarm:children]
managers
workers

[all:vars]
ansible_ssh_private_key_file=~/.ssh/your-key.pem
swarm_manager_ip=<MANAGER_PRIVATE_IP>
```

### 2.4 playbook.yml - Main Orchestrator
```yaml
---
- name: Setup Docker Swarm Cluster
  hosts: all
  become: yes
  gather_facts: yes
  roles:
    - common

- name: Install Docker
  hosts: swarm
  become: yes
  roles:
    - docker

- name: Initialize Swarm Manager
  hosts: managers
  become: yes
  roles:
    - swarm-manager

- name: Join Workers to Swarm
  hosts: workers
  become: yes
  roles:
    - swarm-worker

- name: Setup Reverse Proxy (Traefik with Auto SSL)
  hosts: managers
  become: yes
  roles:
    - reverse-proxy

- name: Setup Monitoring
  hosts: managers
  become: yes
  roles:
    - monitoring
```

### 2.5 roles/common/tasks/main.yml
```yaml
---
- name: Update system packages
  apt:
    update_cache: yes
    upgrade: dist
    cache_valid_time: 3600

- name: Install required packages
  apt:
    name:
      - curl
      - wget
      - git
      - htop
      - net-tools
      - jq
      - ca-certificates
      - apt-transport-https
    state: present

- name: Create non-root user for Swarm management
  user:
    name: docker
    groups: docker
    append: yes

- name: Ensure SSH directory exists for docker user
  file:
    path: /home/docker/.ssh
    state: directory
    owner: docker
    group: docker
    mode: '0700'
```

### 2.6 roles/docker/tasks/main.yml
```yaml
---
- name: Add Docker GPG key
  apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present

- name: Add Docker repository
  apt_repository:
    repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
    state: present

- name: Install Docker CE
  apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-compose-plugin
    state: present
    update_cache: yes

- name: Enable Docker service
  systemd:
    name: docker
    state: started
    enabled: yes

- name: Add user to docker group
  user:
    name: ubuntu
    groups: docker
    append: yes
```

### 2.7 roles/swarm-manager/tasks/main.yml
```yaml
---
- name: Initialize Swarm on Manager
  command: docker swarm init --advertise-addr {{ hostvars[groups['managers'][0]]['ansible_host'] }}
  register: swarm_init
  changed_when: "'Swarm initialized' in swarm_init.stdout or 'This node is already part of a swarm' in swarm_init.stderr"

- name: Get Swarm join token for workers
  command: docker swarm join-token -q worker
  register: worker_token

- name: Save worker token to fact
  set_fact:
    swarm_worker_token: "{{ worker_token.stdout }}"

- name: Share token with other hosts
  debug:
    msg: "Worker join token: {{ swarm_worker_token }}"
```

### 2.8 roles/swarm-worker/tasks/main.yml
```yaml
---
- name: Join worker to Swarm
  command: "docker swarm join --token {{ hostvars[groups['managers'][0]]['swarm_worker_token'] }} {{ hostvars[groups['managers'][0]]['swarm_manager_ip'] }}:2377"
  register: swarm_join
  changed_when: "'This node joined a swarm as a worker' in swarm_join.stdout or 'This node is already part of a swarm' in swarm_join.stderr"
```

### 2.9 roles/reverse-proxy/tasks/main.yml (Traefik)
```yaml
---
- name: Create Traefik config directory
  file:
    path: /opt/traefik
    state: directory

- name: Copy Traefik compose file
  template:
    src: traefik-compose.yml.j2
    dest: /opt/traefik/docker-compose.yml

- name: Deploy Traefik stack
  command: docker stack deploy -c /opt/traefik/docker-compose.yml traefik
  register: traefik_deploy
  changed_when: "'was updated' in traefik_deploy.stdout or 'was created' in traefik_deploy.stdout"
```

### 2.10 roles/monitoring/tasks/main.yml (Note: SSL handled by Traefik auto-certification)
```yaml
---
- name: Create monitoring directories
  file:
    path: /opt/monitoring/{{ item }}
    state: directory
  loop:
    - prometheus
    - grafana
    - node-exporter

- name: Copy Prometheus config
  template:
    src: prometheus.yml.j2
    dest: /opt/monitoring/prometheus/prometheus.yml

- name: Deploy monitoring stack
  command: docker stack deploy -c /opt/monitoring/docker-compose.yml monitoring
  register: monitoring_deploy
  changed_when: "'was updated' in monitoring_deploy.stdout or 'was created' in monitoring_deploy.stdout"
```

### 2.12 Run Ansible Playbook
- [ ] Verify SSH access to all nodes: `ansible -i inventory.ini all -m ping`
- [ ] Run full playbook: `ansible-playbook playbook.yml -v`
- [ ] Verify Swarm cluster: `ssh ubuntu@<MANAGER_IP> "docker node ls"`
- [ ] Check Docker services running: `docker service ls`

---

## 🐳 PHẦN 3: DOCKER SWARM CONFIGURATION

### 3.1 Project Structure
```
swarm/
├── app.yml               ← Main application stack
├── monitoring.yml        ← Prometheus + Grafana stack
├── traefik.yml          ← Traefik reverse proxy stack (optional)
└── volumes/
    ├── prometheus-data/
    ├── grafana-data/
    └── app-data/
```

### 3.2 app.yml - Application Stack ĐÃ LÀM
```yaml
version: '3.8'
services:
  backend:
    image: ${ECR_BACKEND}:${VERSION}
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=mongodb://mongo:27017/app
      - NODE_ENV=production
      - LOG_LEVEL=info
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      update_config:
        parallelism: 1
        delay: 10s
      placement:
        constraints:
          - node.role != manager
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s
    networks:
      - app-network
    labels:
      traefik.enable: "true"
      traefik.http.routers.backend.rule: "Host(`api.yourdomain.com`)"
      traefik.http.services.backend.loadbalancer.server.port: "3000"

  frontend:
    image: ${ECR_FRONTEND}:${VERSION}
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
      update_config:
        parallelism: 1
        delay: 10s
      placement:
        constraints:
          - node.role == worker
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    networks:
      - app-network
    labels:
      traefik.enable: "true"
      traefik.http.routers.frontend.rule: "Host(`yourdomain.com`)"
      traefik.http.services.frontend.loadbalancer.server.port: "80"

  mongo:
    image: mongo:7
    volumes:
      - mongo-data:/data/db
    environment:
      MONGO_INITDB_DATABASE: app
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      placement:
        constraints:
          - node.role == worker
    networks:
      - app-network

volumes:
  mongo-data:
    driver: local

networks:
  app-network:
    driver: overlay
    driver_opts:
      com.docker.network.driver.overlay.vxlanid: "4096"
```

### 3.3 monitoring.yml - Monitoring Stack ĐÃ LÀM
```yaml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - /opt/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    deploy:
      placement:
        constraints:
          - node.role == manager
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
    deploy:
      placement:
        constraints:
          - node.role == manager
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    deploy:
      mode: global
    networks:
      - monitoring

volumes:
  prometheus-data:
    driver: local
  grafana-data:
    driver: local

networks:
  monitoring:
    driver: overlay
```

### 3.4 Deploy Swarm Stacks
- [ ] SSH to manager: `ssh ubuntu@<MANAGER_IP>`
- [ ] Deploy app: `docker stack deploy -c app.yml app`
- [ ] Deploy monitoring: `docker stack deploy -c monitoring.yml monitoring`
- [ ] Verify: `docker stack ls` && `docker service ls`

---

## 🔁 PHẦN 4: CI/CD PIPELINE (GitHub Actions)

### 4.1 Project Structure
```
.github/workflows/
├── ci.yml               ← Continuous Integration
└── cd.yml               ← Continuous Deployment
```

### 4.2 .github/workflows/ci.yml - CI Pipeline ĐÃ LÀM
```yaml
name: CI Pipeline

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm install
        working-directory: ./src
      
      - name: Run Linter (ESLint)
        run: npm run lint || true
        working-directory: ./src
      
      - name: Run Tests
        run: npm test || true
        working-directory: ./src
      
      - name: Build application
        run: npm run build || true
        working-directory: ./src
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build Backend Docker Image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: finaldevops/backend
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./src
      
      - name: Scan Docker Image (Trivy)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ steps.login-ecr.outputs.registry }}/finaldevops/backend:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Push Docker Image to ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: finaldevops/backend
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "IMAGE_URI=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_ENV
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: build-info
          path: |
            .github/workflows/cd.yml
            swarm/app.yml
```

### 4.3 .github/workflows/cd.yml - CD Pipeline ĐÃ LÀM
```yaml
name: CD Pipeline

on:
  workflow_run:
    workflows: ["CI Pipeline"]
    types: [completed]
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}
      
      - name: Get commit SHA from workflow run
        id: commit
        run: echo "sha=${{ github.event.workflow_run.head_sha }}" >> $GITHUB_OUTPUT
      
      - name: Deploy to Swarm via SSH
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SWARM_MANAGER_IP }}
          username: ubuntu
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /opt/app
            export ECR_BACKEND=${{ secrets.ECR_BACKEND_URI }}:${{ steps.commit.outputs.sha }}
            export ECR_FRONTEND=${{ secrets.ECR_FRONTEND_URI }}:${{ steps.commit.outputs.sha }}
            export VERSION=${{ steps.commit.outputs.sha }}
            docker stack deploy -c swarm/app.yml app
            docker service update --force app_backend
            docker service update --force app_frontend
      
      - name: Verify Deployment
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SWARM_MANAGER_IP }}
          username: ubuntu
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            sleep 10
            docker service ls
            docker service ps app_backend
            docker service ps app_frontend
```

### 4.4 CI/CD Validation
- [ ] Push code to GitHub → trigger CI
- [ ] Verify linting passes
- [ ] Verify build succeeds
- [ ] Verify image scanned (no critical vulnerabilities)
- [ ] Verify image pushed to ECR with version tag (NOT latest)
- [ ] Verify CD triggered after CI success
- [ ] Verify Swarm deployment updated
- [ ] Verify application accessible via HTTPS domain

---

## 📊 PHẦN 5: MONITORING & OBSERVABILITY

### 5.1 Prometheus Configuration
```yaml
# /opt/monitoring/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'docker-swarm'
    static_configs:
      - targets: ['localhost:8080']

  - job_name: 'backend-app'
    static_configs:
      - targets: ['backend:3000']
    metrics_path: '/metrics'
```

### 5.2 Grafana Dashboards
- [ ] Access Grafana: `https://yourdomain.com:3001`
- [ ] Login: admin / admin (change password)
- [ ] Add Prometheus data source: `http://prometheus:9090`
- [ ] Import or create dashboards:
  - [ ] Node Exporter Dashboard (CPU, Memory, Disk)
  - [ ] Docker Swarm Dashboard (Services, Tasks, Replicas)
  - [ ] Custom App Metrics (Requests/sec, Error rate)

### 5.3 Alerting Rules (Optional)
```yaml
# /opt/monitoring/prometheus/alerts.yml
groups:
  - name: swarm
    rules:
      - alert: HighCPU
        expr: (100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)) > 80
        for: 5m
      
      - alert: HighMemory
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
      
      - alert: ServiceDown
        expr: up{job=~"backend-app|frontend-app"} == 0
        for: 1m
```

### 5.4 Monitoring Validation
- [ ] Prometheus scraping all targets
- [ ] Grafana displaying real-time metrics
- [ ] All nodes showing CPU/Memory data
- [ ] Container metrics visible
- [ ] Application metrics available

---

## 🧰 PHẦN 6: AUTOMATION SCRIPTS

### 6.1 scripts/setup.sh - Initial Setup
```bash
#!/bin/bash
set -e

echo "Starting infrastructure setup..."

# Export variables
export AWS_REGION=${AWS_REGION:-us-east-1}
export PROJECT_NAME=${PROJECT_NAME:-finaldevops}

# Terraform
cd infra/
terraform init
terraform plan
terraform apply -auto-approve
MANAGER_IP=$(terraform output -raw swarm_manager_ip)
export MANAGER_IP

# Save outputs
terraform output > ../outputs.json

cd ..

echo "Infrastructure created successfully!"
echo "Manager IP: $MANAGER_IP"
```

### 6.2 scripts/deploy.sh - Deploy Application
```bash
#!/bin/bash
set -e

MANAGER_IP=$1
DOMAIN=$2

if [ -z "$MANAGER_IP" ] || [ -z "$DOMAIN" ]; then
  echo "Usage: ./deploy.sh <MANAGER_IP> <DOMAIN>"
  exit 1
fi

echo "Deploying to Swarm..."

ssh -i ~/.ssh/your-key.pem ubuntu@$MANAGER_IP << 'EOF'
cd /opt/app
export VERSION=$(git rev-parse --short HEAD)
docker stack deploy -c swarm/app.yml app
docker service ls
EOF

echo "Deployment complete! Access at: https://$DOMAIN"
```

### 6.3 scripts/rollback.sh - Rollback Deployment
```bash
#!/bin/bash
set -e

MANAGER_IP=$1
PREVIOUS_VERSION=$2

if [ -z "$MANAGER_IP" ] || [ -z "$PREVIOUS_VERSION" ]; then
  echo "Usage: ./rollback.sh <MANAGER_IP> <PREVIOUS_VERSION>"
  exit 1
fi

echo "Rolling back to version: $PREVIOUS_VERSION"

ssh -i ~/.ssh/your-key.pem ubuntu@$MANAGER_IP << EOF
docker service update --image <ECR_URI>:$PREVIOUS_VERSION app_backend
docker service update --image <ECR_URI>:$PREVIOUS_VERSION app_frontend
EOF

echo "Rollback complete!"
```

### 6.4 scripts/simulate-failure.sh - Test Failover
```bash
#!/bin/bash

MANAGER_IP=$1

ssh -i ~/.ssh/your-key.pem ubuntu@$MANAGER_IP << 'EOF'
# Kill a container to test self-healing
CONTAINER=$(docker ps -q | head -1)
echo "Killing container: $CONTAINER"
docker kill $CONTAINER

# Monitor recovery
echo "Monitoring service recovery..."
for i in {1..10}; do
  docker service ps app_backend
  sleep 2
done
EOF
```

### 6.5 scripts/cleanup.sh - Destroy Infrastructure
```bash
#!/bin/bash

echo "WARNING: This will destroy all infrastructure!"
read -p "Continue? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
  cd infra/
  terraform destroy -auto-approve
  echo "Infrastructure destroyed!"
else
  echo "Aborted."
fi
```

---

## 📋 PHẦN 7: DOCUMENTATION

### 7.1 README.md (Root)
- [ ] Project overview
- [ ] Architecture diagram
- [ ] Prerequisites
- [ ] Quick start guide
- [ ] Deployment instructions
- [ ] Monitoring access
- [ ] Troubleshooting

### 7.2 infra/README.md
- [ ] Terraform file descriptions
- [ ] How to initialize
- [ ] How to deploy
- [ ] How to destroy
- [ ] AWS costs estimation

### 7.3 ansible/README.md
- [ ] Ansible roles descriptions
- [ ] How to run playbook
- [ ] How to troubleshoot

### 7.4 swarm/README.md
- [ ] Docker Swarm setup details
- [ ] Stack deployment instructions
- [ ] Service descriptions
- [ ] Scaling instructions

### 7.5 .github/workflows/README.md
- [ ] CI/CD pipeline flow
- [ ] Secrets configuration
- [ ] How to trigger manually

---

## 🎬 PHẦN 8: DEMO SCRIPT (BẮTBUỘC)

### Demo Flow (Video hoặc Live)
Trước khi quay thì vào file index.ejs xóa cái comment chổ nút REFRESH dưới nút ADD PRODUCT sau đó lưu. ĐẢM BẢO ĐANG CHẠY ỔN ĐỊNH VÀ CHƯA HIỂN THIN CÁI NÚT NÀY.

1. **Code Change**
   - [ ] Edit source code (UI change or feature)
   - [ ] Show modified files

chổ này nói "đây là giao diện hiện tại của chúng em"

2. **Commit & Push**
   - [ ] `git add . && git commit -m "feat: demo update"`
   - [ ] `git push origin main`
nói " bây giờ em sẽ cập nhật UI, thêm nút REFRESH"
sau đó gõ lệnh commit

3. **CI Pipeline Execution**
   - [ ] Show GitHub Actions running
   - [ ] Show lint passing
   - [ ] Show build succeeding
   - [ ] Show security scan (Trivy)
   - [ ] Show image pushed to ECR

4. **CD Pipeline Execution**
   - [ ] Show deployment trigger
   - [ ] Show SSH commands executing
   - [ ] Show `docker stack deploy` command
   - [ ] Show services updating

5. **Verify Application Update**
   - [ ] Open browser: `https://yourdomain.com`
   - [ ] Confirm code change visible (UI update)
   - [ ] Show backend API responding

6. **Show Monitoring**
   - [ ] Open Grafana: `https://yourdomain.com:3001`
   - [ ] Show CPU/Memory metrics
   - [ ] Show service replicas

7. **Simulate Failure & Recovery**
   - [ ] SSH to manager
   - [ ] Kill a container: `docker kill <CONTAINER_ID>`
   - [ ] Show Swarm auto-recovering
   - [ ] Show new container starting
   - [ ] Show alert in Grafana (if configured)

8. **Verify System Stability**
   - [ ] Application still accessible
   - [ ] All services healthy
   - [ ] Grafana showing recovery

---

## ✅ PHẦN 9: FINAL CHECKLIST & VALIDATION

### Infrastructure
- [ ] 1 Manager + 2 Workers running on EC2
- [ ] Security Groups configured correctly
- [ ] ECR repositories created
- [ ] Terraform state backed up

### Configuration
- [ ] Ansible playbook executed successfully
- [ ] All nodes SSH-accessible
- [ ] Docker installed on all nodes
- [ ] Swarm cluster initialized

### Docker Swarm
- [ ] `docker node ls` shows 3 nodes (1 manager, 2 workers)
- [ ] App stack deployed: `docker stack ls`
- [ ] Services running: `docker service ls` shows backend, frontend, mongo
- [ ] All replicas healthy (2 backend, 2 frontend)

### CI/CD
- [ ] GitHub Actions workflows configured
- [ ] ECR images built with version tags
- [ ] Deployment automated
- [ ] No manual deployments needed

### Domain & HTTPS
- [ ] Domain resolves to Load Balancer/Manager IP
- [ ] HTTPS accessible: `https://yourdomain.com`
- [ ] SSL certificate valid
- [ ] No certificate warnings

### Monitoring
- [ ] Prometheus scraping metrics
- [ ] Grafana dashboards displaying data
- [ ] All nodes monitored
- [ ] Application metrics available

### Demo
- [ ] Video recorded or live demonstration
- [ ] Code change visible in app
- [ ] Pipeline execution clear
- [ ] Failover test successful

---

## 📦 PHẦN 10: DELIVERABLES CHECKLIST

### Files to Submit
- [ ] GitHub repo link (public or with access token)
- [ ] `/infra` - All Terraform files
- [ ] `/ansible` - All Ansible roles
- [ ] `/swarm` - Docker stack files
- [ ] `.github/workflows/` - CI/CD pipelines
- [ ] `/src` - Application code
- [ ] `Makefile` - Build automation
- [ ] `/scripts` - Deployment scripts
- [ ] `/docs` - Architecture diagrams, design docs

### Reports & Documentation
- [ ] Technical Report (PDF, English, 5 chapters)
  - [ ] Chapter 1: Overview & Architecture
  - [ ] Chapter 2: Infrastructure (Terraform + AWS)
  - [ ] Chapter 3: CI/CD Design & Implementation
  - [ ] Chapter 4: Deployment & Orchestration (Docker Swarm)
  - [ ] Chapter 5: Monitoring & Lessons Learned

### Public Access
- [ ] Production URL: `https://yourdomain.com` (HTTPS working)
- [ ] API endpoint: `https://yourdomain.com/api` (responding)
- [ ] Grafana dashboard: `https://yourdomain.com:3001` (credentials provided)
- [ ] ECR repositories linked
- [ ] GitHub repo with full history

### Demo Materials
- [ ] Video demo (5-10 minutes)
- [ ] Screenshots of each stage
- [ ] Monitoring dashboard snapshot

---

## 🎯 PHẦN 11: EXTRA CREDIT (OPTIONAL - +0.25-0.5 POINTS EACH)

- [ ] **Auto-Rollback**: System automatically rolls back on deployment failure
- [ ] **Blue-Green Deployment**: Zero-downtime deployments
- [ ] **Canary Releases**: Gradual rollout to subset of users
- [ ] **Multi-Environment**: Staging + Production with approval gate
- [ ] **Advanced Logging**: ELK stack or Loki + Promtail
- [ ] **Backup & DR**: Automated backup + recovery procedure
- [ ] **Infrastructure as Code Best Practices**: S3 state, DynamoDB lock, modules
- [ ] **Custom Metrics**: Application business metrics in Prometheus

---

## 🚀 ORDER OF EXECUTION (RECOMMENDED)

1. **Phase 0**: Setup AWS credentials, GitHub, domain (1-2 hours)
2. **Phase 1**: Write & apply Terraform (2-3 hours)
3. **Phase 2**: Write & run Ansible playbooks (1-2 hours)
4. **Phase 3**: Deploy Swarm stacks (1 hour)
5. **Phase 4**: Configure CI/CD pipelines (1-2 hours)
6. **Phase 5**: Setup monitoring (1 hour)
7. **Phase 6**: Documentation & demo (2-3 hours)
8. **Phase 7**: Testing & validation (1-2 hours)

**Total Estimated Time: 10-16 hours**

---

**Last Updated**: May 2, 2026  
**Ready to Start**: ✅ YES
