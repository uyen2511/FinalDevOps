.PHONY: all build deploy test clean

# Variables
DOCKER_IMAGE_BACKEND = finaldevops/backend
DOCKER_IMAGE_FRONTEND = finaldevops/frontend
TAG ?= latest

all: build

build:
	@echo "Building Docker image for backend..."
	docker build -t $(DOCKER_IMAGE_BACKEND):$(TAG) .

deploy:
	@echo "Deploying to Docker Swarm..."
	bash scripts/deploy.sh

rollback:
	@echo "Rolling back Swarm deployment..."
	bash scripts/rollback.sh

simulate-failure:
	@echo "Simulating failure..."
	bash scripts/simulate-failure.sh

test:
	@echo "Running tests..."
	npm test --prefix src

clean:
	@echo "Cleaning up..."
	docker system prune -f
