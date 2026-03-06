#!/bin/bash

# Update system
sudo apt update -y

# Install Java (required for Jenkins)
sudo apt install -y fontconfig openjdk-21-jre

# Verify Java installation
java -version

# Add Jenkins repository key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Add Jenkins repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list again
sudo apt update -y

# Install Jenkins
sudo apt install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins