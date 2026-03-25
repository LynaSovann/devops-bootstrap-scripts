#!/bin/bash

# -------- LOGGING --------
exec > /var/log/user-data-loki.log 2>&1
set -x

# -------- WAIT FOR NETWORK --------
sleep 10

# -------- INSTALL DEPENDENCIES --------
apt-get update -y
apt-get install -y wget curl unzip

# -------- GET LATEST VERSION --------
LOKI_VERSION=$(curl -s https://api.github.com/repos/grafana/loki/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')

# -------- CREATE DIR --------
mkdir -p /opt/loki
cd /opt/loki

# -------- DOWNLOAD (USE ZIP CORRECTLY) --------
wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip

# -------- EXTRACT --------
unzip loki-linux-amd64.zip

# -------- SET EXECUTABLE --------
chmod +x loki-linux-amd64
mv loki-linux-amd64 loki

# -------- SYMLINK --------
ln -sf /opt/loki/loki /usr/local/bin/loki

# -------- DOWNLOAD CONFIG --------
wget -qO /opt/loki/loki-local-config.yaml \
https://raw.githubusercontent.com/grafana/loki/v${LOKI_VERSION}/cmd/loki/loki-local-config.yaml

# -------- CREATE LOKI USER (BEST PRACTICE) --------
id -u loki || useradd -r -s /bin/false loki

# -------- PERMISSIONS --------
chown -R loki:loki /opt/loki

# -------- SYSTEMD SERVICE --------
cat <<EOF > /etc/systemd/system/loki.service
[Unit]
Description=Loki log aggregation system
After=network.target

[Service]
User=loki
Group=loki
ExecStart=/opt/loki/loki -config.file=/opt/loki/loki-local-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# -------- START SERVICE --------
systemctl daemon-reload
systemctl enable loki
systemctl restart loki

# -------- VERIFY --------
sleep 5
systemctl status loki --no-pager
