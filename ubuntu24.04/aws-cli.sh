#!/bin/bash

# Exit on any error
set -e

echo "Installing AWS CLI v2 via Snap..."

# Install AWS CLI
sudo snap install aws-cli --classic

# Verify installation
aws --version
