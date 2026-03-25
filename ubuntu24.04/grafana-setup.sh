#!/bin/bash

exec > /var/log/user-data.log 2>&1
set -x

sleep 10

apt-get update -y
apt-get install -y wget tar

cd /tmp

wget https://dl.grafana.com/grafana-enterprise/release/12.4.1/grafana-enterprise_12.4.1_22846628243_linux_amd64.tar.gz

tar -zxvf grafana-enterprise_12.4.1_22846628243_linux_amd64.tar.gz

# -------- USER --------
id -u grafana || useradd -r -s /bin/false grafana

# -------- INSTALL --------
mkdir -p /usr/local/grafana
cp -r grafana-12.4.1/* /usr/local/grafana/

# -------- CONFIG --------
cp /usr/local/grafana/conf/sample.ini /usr/local/grafana/conf/grafana.ini

# -------- CREATE REQUIRED DIRS (THIS IS THE KEY FIX) --------
mkdir -p /usr/local/grafana/data
mkdir -p /usr/local/grafana/log
mkdir -p /usr/local/grafana/plugins

# -------- PERMISSIONS --------
chown -R grafana:grafana /usr/local/grafana

# -------- SYSTEMD --------
cat <<EOF > /etc/systemd/system/grafana-server.service
[Unit]
Description=Grafana Server
After=network.target

[Service]
Type=simple
User=grafana
Group=grafana
ExecStart=/usr/local/grafana/bin/grafana server \
  --config=/usr/local/grafana/conf/grafana.ini \
  --homepath=/usr/local/grafana
Restart=on-failure
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
PrivateUsers=false

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable grafana-server
systemctl restart grafana-server
