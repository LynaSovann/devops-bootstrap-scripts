#!/bin/bash

# -------- LOGGING --------
exec > /var/log/user-data-prometheus.log 2>&1
set -x

# -------- WAIT FOR NETWORK --------
sleep 10

# -------- UPDATE --------
apt-get update -y
apt-get install -y wget tar

# -------- VARIABLES --------
VERSION="2.55.1"
FILE="prometheus-${VERSION}.linux-amd64.tar.gz"
DIR="prometheus-${VERSION}.linux-amd64"

cd /tmp

# -------- DOWNLOAD --------
wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/${FILE}

# -------- EXTRACT --------
tar -xvf ${FILE}

# -------- CREATE USER --------
getent group prometheus || groupadd --system prometheus
id -u prometheus || useradd -s /sbin/nologin --system -g prometheus prometheus

# -------- CREATE DIRECTORIES --------
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

# -------- INSTALL BINARIES --------
cp ${DIR}/prometheus /usr/local/bin/
cp ${DIR}/promtool /usr/local/bin/

# -------- SET PERMISSIONS --------
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# -------- CONFIG FILES --------
cp -r ${DIR}/consoles /etc/prometheus
cp -r ${DIR}/console_libraries /etc/prometheus
cp ${DIR}/prometheus.yml /etc/prometheus

# -------- PERMISSIONS --------
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus

# -------- CREATE SYSTEMD SERVICE --------
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \\
    --config.file=/etc/prometheus/prometheus.yml \\
    --storage.tsdb.path=/var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries \\
    --web.listen-address=0.0.0.0:9090 \\
    --web.enable-lifecycle \\
    --log.level=info

[Install]
WantedBy=multi-user.target
EOF

# -------- START SERVICE --------
systemctl daemon-reload
systemctl enable prometheus
systemctl restart prometheus

# -------- VERIFY --------
sleep 5
systemctl status prometheus --no-pager
