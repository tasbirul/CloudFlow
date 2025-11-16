#!/bin/bash
set -e

# Variables from Terraform
ECR_REPO_URL=${ecr_repo_url}
CONTAINER_PORT=${container_port}
AWS_REGION=${aws_region}
USER_NAME=ubuntu

# Update system & install Docker
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Add user to Docker group
sudo groupadd docker || true
sudo usermod -aG docker $USER_NAME
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose version || true

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install -y unzip
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
aws --version


# Authenticate Docker with ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL