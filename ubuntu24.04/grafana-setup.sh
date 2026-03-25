
wget https://dl.grafana.com/grafana-enterprise/release/12.4.1/grafana-enterprise_12.4.1_22846628243_linux_amd64.tar.gz

tar -zxvf grafana-enterprise_12.4.1_22846628243_linux_amd64.tar.gz

sudo useradd -r -s /bin/false grafana

 mkdir /usr/local/grafana

 sudo mv grafana-12.4.1/* /usr/local/grafana/
sudo chown -R grafana:users /usr/local/grafana

sudo touch /etc/systemd/system/grafana-server.service

vim /etc/systemd/system/grafana-server.service

# add this 
[Unit]
Description=Grafana Server
After=network.target

[Service]
Type=simple
User=grafana
Group=users
ExecStart=/usr/local/grafana/bin/grafana server --config=/usr/local/grafana/conf/grafana.ini --homepath=/usr/local/grafana
Restart=on-failure

[Install]
WantedBy=multi-user.target

## 

cd /usr/local/grafana/conf
sudo cp sample.ini grafana.ini

/usr/local/grafana/bin/grafana server --homepath /usr/local/grafana

ctrl + c

sudo chown -R grafana:users /usr/local/grafana

#Configure the Grafana server to start at boot using systemd
sudo systemctl enable grafana-server.service

sudo EDITOR=vim systemctl edit grafana-server.service

## add this
[Service]
# Give the CAP_NET_BIND_SERVICE capability
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE

# A private user cannot have process capabilities on the host's user
# namespace and thus CAP_NET_BIND_SERVICE has no effect.
PrivateUsers=false

## 

sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl restart grafana-server


