#!/bin/bash
set -e

echo "=== 1. Updating System Packages & Installing Dependencies ==="
sudo apt-get update -y
sudo apt-get install -y wget curl gnupg software-properties-common ca-certificates

echo "=== 2. Configuring Jenkins GPG Key & Repository ==="
# Ensure old/conflicting keyrings and list files are removed
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /usr/share/keyrings/jenkins-keyring.gpg

# Download official Jenkins 2023 key and de-armor into binary keyring
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg

# Receive and append the rotated GPG public key (7198F4B714ABFC68) to the keyring
gpg --keyserver keyserver.ubuntu.com --recv-keys 7198F4B714ABFC68
gpg --export 7198F4B714ABFC68 | sudo tee -a /usr/share/keyrings/jenkins-keyring.gpg > /dev/null

# Configure repository with signed-by option pointing to the binary .gpg file
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "=== 3. Installing Jenkins ==="
sudo apt-get update -y
sudo apt-get install -y jenkins