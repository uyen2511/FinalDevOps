resource "aws_security_group" "swarm" {
  name        = "${var.project_name}-swarm-sg"
  description = "Security group for Docker Swarm nodes"
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application backend port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Grafana port
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Swarm management
  ingress {
    from_port       = 2377
    to_port         = 2377
    protocol        = "tcp"
    self            = true
  }

  # Swarm overlay network
  ingress {
    from_port       = 4789
    to_port         = 4789
    protocol        = "udp"
    self            = true
  }

  # Swarm node communication
  ingress {
    from_port       = 7946
    to_port         = 7946
    protocol        = "tcp"
    self            = true
  }

  ingress {
    from_port       = 7946
    to_port         = 7946
    protocol        = "udp"
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-swarm-sg"
  }
}
