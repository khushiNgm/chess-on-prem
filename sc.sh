#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Updating system packages..."
sudo yum update -y

echo "Installing Docker..."
# Check OS version to determine the correct installation method
if grep -q "Amazon Linux 2023" /etc/os-release; then
    echo "Detected Amazon Linux 2023. Using dnf..."
    sudo dnf install -y docker
else
    echo "Detected Amazon Linux 2. Using amazon-linux-extras..."
    sudo amazon-linux-extras install -y docker
fi

echo "Starting and enabling the Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Adding the current user to the Docker group..."
# On EC2, this is typically the 'ec2-user'
sudo usermod -aG docker $USER

echo "Installing Docker Compose..."
# Downloads the latest release binary for the specific architecture (x86_64 or aarch64)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

echo "Applying executable permissions to Docker Compose..."
sudo chmod +x /usr/local/bin/docker-compose

# Create a symlink just in case /usr/local/bin isn't in the path for some services
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "--- Installation Complete! ---"
docker --version
docker-compose --version