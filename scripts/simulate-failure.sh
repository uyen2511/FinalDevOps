#!/bin/bash

MANAGER_IP=$1

if [ -z "$MANAGER_IP" ]; then
  echo "Usage: ./simulate-failure.sh <MANAGER_IP>"
  exit 1
fi

ssh -i ../finaldevops-key.pem ubuntu@$MANAGER_IP << 'EOF'
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
