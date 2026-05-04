ssh -o StrictHostKeyChecking=no -i /tmp/ssh_key/finaldevops-key.pem ubuntu@32.192.41.188 << 'EOF'
sudo mkdir -p /opt/app /opt/monitoring/prometheus
sudo chown -R ubuntu:ubuntu /opt/app /opt/monitoring
git clone https://github.com/kaykayhmwr/DevOpsFinaL.git /opt/app || true

cat << 'PROMETHEUS' > /opt/monitoring/prometheus/prometheus.yml
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

  - job_name: 'backend-app'
    static_configs:
      - targets: ['backend:3000']
    metrics_path: '/metrics'
PROMETHEUS

docker stack deploy -c /opt/app/swarm/monitoring.yml monitoring
EOF
