#!/bin/bash
set -e


# 1. Update system and install Docker

echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing Docker..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release unzip
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu


# 2. Install AWS CLI

echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Configure AWS Region
export AWS_DEFAULT_REGION=${aws_region}


# 3. Wait for IAM instance profile to become available

echo "Waiting for instance profile..."
sleep 30

# 4. Prepare ECR pull & run script

cat > /home/ubuntu/pull_and_run.sh << 'EOF'
#!/bin/bash
set -e
export AWS_DEFAULT_REGION=${aws_region}

# Authenticate to ECR
aws ecr get-login-password --region ${aws_region} | sudo docker login --username AWS --password-stdin ${ecr_repo_url}

# Stop existing container if running
sudo docker stop nodejs-app 2>/dev/null || true
sudo docker rm nodejs-app 2>/dev/null || true

# Pull latest image and run
sudo docker pull ${ecr_repo_url}:latest
sudo docker run -d --name nodejs-app --restart always -p 80:3000 ${ecr_repo_url}:latest

echo "Container started!"
sudo docker ps
EOF

chmod +x /home/ubuntu/pull_and_run.sh
chown ubuntu:ubuntu /home/ubuntu/pull_and_run.sh

# 5. Create systemd service to run container on boot

cat > /etc/systemd/system/nodejs-app.service << 'EOF'
[Unit]
Description=Node.js Docker Container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/home/ubuntu/pull_and_run.sh
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nodejs-app.service

echo "User data setup completed!"