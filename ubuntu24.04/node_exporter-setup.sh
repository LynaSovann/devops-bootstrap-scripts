#!/bin/bash

# -------- LOGGING --------
exec > /var/log/user-data-node-exporter.log 2>&1
set -x

# -------- WAIT FOR NETWORK --------
sleep 10

# -------- INSTALL DEPENDENCIES --------
apt-get update -y
apt-get install -y wget tar

# -------- VERSION --------
VERSION="1.8.2"
FILE="node_exporter-${VERSION}.linux-amd64.tar.gz"
DIR="node_exporter-${VERSION}.linux-amd64"

cd /tmp

# -------- DOWNLOAD --------
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${FILE}

# -------- EXTRACT --------
tar -xvf ${FILE}

# -------- CREATE USER --------
id -u node_exporter || useradd --no-create-home --shell /bin/false node_exporter

# -------- INSTALL BINARY --------
cp ${DIR}/node_exporter /usr/local/bin/

# -------- PERMISSIONS --------
chown node_exporter:node_exporter /usr/local/bin/node_exporter
chmod +x /usr/local/bin/node_exporter

# -------- CREATE SERVICE --------
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.systemd
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# -------- START SERVICE --------
systemctl daemon-reload
systemctl enable node_exporter
systemctl restart node_exporter

# -------- VERIFY --------
sleep 5
systemctl status node_exporter --no-pager
