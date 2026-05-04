#!/bin/bash
set -e

MANAGER_IP=$1
DOMAIN=$2

if [ -z "$MANAGER_IP" ] || [ -z "$DOMAIN" ]; then
  echo "Usage: ./deploy.sh <MANAGER_IP> <DOMAIN>"
  exit 1
fi

echo "Deploying to Swarm..."

ssh -i ~/.ssh/finaldevops-key.pem ubuntu@$MANAGER_IP << 'EOF'
cd /opt/app
git pull origin main
export VERSION=$(git rev-parse --short HEAD)
docker stack deploy -c swarm/app.yml app
docker service ls
EOF

echo "Deployment complete! Access at: https://$DOMAIN"
