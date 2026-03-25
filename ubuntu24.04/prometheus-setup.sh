sudo  apt update

sudo groupadd --system prometheus

sudo useradd -s /sbin/nologin --system -g prometheus prometheus

sudo mkdir /etc/prometheus

sudo mkdir /var/lib/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.55.1/prometheus-2.55.1.linux-amd64.tar.gz


tar xvf prometheus-2.55.1.linux-*

sudo mv prometheus-2.55.1.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-2.55.1.linux-amd64/promtool /usr/local/bin/

sudo chown -R  prometheus:prometheus /usr/local/bin/prometheus
sudo chown -R  prometheus:prometheus /usr/local/bin/promtool

sudo mv prometheus-2.55.1.linux-amd64/consoles /etc/prometheus
sudo mv prometheus-2.55.1.linux-amd64/console_libraries /etc/prometheus

sudo mv prometheus-2.55.1.linux-amd64/prometheus.yml /etc/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

sudo vim /etc/systemd/system/prometheus.service

## 
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
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle \
    --log.level=info

[Install]
WantedBy=multi-user.target

## 
sudo systemctl daemon-reload

sudo systemctl start prometheus

sudo systemctl enable prometheus

sudo systemctl status prometheus





