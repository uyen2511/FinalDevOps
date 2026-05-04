#!/bin/bash
set -e

MANAGER_IP=$1
PREVIOUS_VERSION=$2
ECR_BACKEND_URI=$3
ECR_FRONTEND_URI=$4

if [ -z "$MANAGER_IP" ] || [ -z "$PREVIOUS_VERSION" ] || [ -z "$ECR_BACKEND_URI" ]; then
  echo "Usage: ./rollback.sh <MANAGER_IP> <PREVIOUS_VERSION> <ECR_BACKEND_URI> <ECR_FRONTEND_URI>"
  exit 1
fi

echo "Rolling back to version: $PREVIOUS_VERSION"

ssh -i ../finaldevops-key.pem ubuntu@$MANAGER_IP << EOF
docker service update --image $ECR_BACKEND_URI:$PREVIOUS_VERSION app_backend
docker service update --image $ECR_FRONTEND_URI:$PREVIOUS_VERSION app_frontend
EOF

echo "Rollback complete!"
