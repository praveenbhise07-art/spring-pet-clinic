#!/bin/bash
set -e

echo "=== 1. Update Packages & Install Dependencies ==="
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk wget curl git unzip apt-transport-https ca-certificates gnupg lsb-release

echo "=== 2. Install Docker & Configure Permissions ==="
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo systemctl enable docker
sudo systemctl start docker

echo "=== 3. Install Jenkins ==="
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

# Grant Jenkins permissions to Docker socket
sudo usermod -aG docker jenkins
sudo chmod 666 /var/run/docker.sock
sudo systemctl enable jenkins
sudo systemctl restart jenkins

echo "=== 4. Run SonarQube in Docker ==="
# SonarQube requires higher max_map_count for Elasticsearch
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

sudo docker run -d --name sonarqube -p 9000:9000 --restart always sonarqube:lts-community

echo "=== 5. Install Trivy (Container Scanner) ==="
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install -y trivy

echo "=== 6. Install Helm & kubectl ==="
# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo "=== 7. Install Azure CLI & Maven ==="
# Maven
sudo apt-get install -y maven

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "=== 8. Verification ==="
echo "Jenkins Status: $(systemctl is-active jenkins)"
echo "Docker Version: $(docker --version)"
echo "Trivy Version: $(trivy --version | head -n 1)"
echo "Helm Version: $(helm version --short)"
echo "Maven Version: $(mvn -version | head -n 1)"
echo "Azure CLI Version: $(az --version | head -n 1)"

echo "=== SETUP COMPLETE ==="
