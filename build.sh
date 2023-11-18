#!/bin/bash
#Provided by adam@wittsgarage.com
#@wittyphantom333

function pause(){
   read -p "$*"
}

echo "=======================">>setup.log 2>>error.log
date>>setup.log 2>>error.log
echo "=======================">>setup.log 2>>error.log

echo "Detecting IP Address"
if [ -z "$LIVE_SERVER_IP" ]; then
    echo "Need to set LIVE_SERVER_IP"
    echo -n "Enter the live servers IP: "
    read liveIP
    $LIVE_SERVER_IP=liveIP
fi
echo "Detected IP Address is $LIVE_SERVER_IP"

echo "Detecting Port"
if [ -z "$LIVE_SERVER_PORT" ]; then
    echo "Need to set LIVE_SERVER_PORT"
    echo -n "Enter the live servers Port: "
    read livePort
    $LIVE_SERVER_PORT=livePort
fi
echo "Detected Port is $LIVE_SERVER_PORT"

echo "Detecting Nginx Port"
if [ -z "$NGINX_LISTEN_PORT" ]; then
    echo "Need to set NGINX_LISTEN_PORT"
    echo -n "Enter the Nginx servers Port: "
    read nginxPort
    $NGINX_LISTEN_PORT=nginxPort
fi
echo "Detected Port is $NGINX_LISTEN_PORT"

echo "Detecting Cache FQDN URL"
if [ -z "$CACHE_SERVER_FQDN_URL" ]; then
    echo "Need to set CACHE_SERVER_FQDN_URL"
    echo -n "Enter the Cache servers FQDN(url): "
    read cacheURL
    $CACHE_SERVER_FQDN_URL=cacheURL
fi
echo "Detected URL is $CACHE_SERVER_FQDN_URL"

echo "Removing incompatible docker versions"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y; done

echo "Adding Docker's official GPG key"
sudo apt-get update >>setup.log 2>>error.log
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "Adding the repository to Apt sources"
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update >>setup.log 2>>error.log

echo "Installing docker and other needed Repositories"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nano git -y

echo "Enabling Docker Service"
systemctl daemon-reload >>setup.log 2>>error.log
systemctl enable docker.service >>setup.log 2>>error.log
systemctl restart docker.service >>setup.log 2>>error.log

echo "Setting nginx.conf values"
sed -i "s/__LIVE_SERVER_IP__/$LIVE_SERVER_IP/g" files/nginx.conf
sed -i "s/__LIVE_SERVER_PORT__/$LIVE_SERVER_PORT/g" files/nginx.conf

echo "Setting docker-compose.yaml values"
sed -i "s/__LIVE_SERVER_IP__/$LIVE_SERVER_IP/g" docker-compose.yml
sed -i "s/__LIVE_SERVER_PORT__/$LIVE_SERVER_PORT/g" docker-compose.yml
sed -i "s/__NGINX_LISTEN_PORT__/$NGINX_LISTEN_PORT/g" docker-compose.yml
sed -i "s/__CACHE_SERVER_FQDN_URL__/$CACHE_SERVER_FQDN_URL/g" docker-compose.yml

echo "Adding user to docker group"
sudo usermod -aG docker $USER

echo "Starting caching container"
docker compose up -d

echo "Installation has completed!!"

