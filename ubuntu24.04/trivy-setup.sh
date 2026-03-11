#!/bin/bash

# Exit on any error
set -e

# Fetch the latest Trivy version from GitHub API
TRIVY_VERSION=$(curl -s "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

echo "Installing Trivy version $TRIVY_VERSION ..."

# Download Trivy tar.gz
wget -qO trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/latest/download/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"

# Extract the binary to /usr/local/bin
sudo tar xf trivy.tar.gz -C /usr/local/bin trivy

# Remove the downloaded tar.gz to clean up
rm trivy.tar.gz

# Verify installation
trivy --version
