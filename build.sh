#!/bin/bash
#Provided by adam@wittsgarage.com
#@wittyphantom333

NGINX_LISTEN_PORT=80
CACHE_SERVER_FQDN_URL=`hostname -f`
function pause(){
   read -p "$*"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=======================${NC}">>setup.log 2>>error.log
date>>setup.log 2>>error.log
echo -e "${BLUE}=======================${NC}">>setup.log 2>>error.log

echo -e "${BLUE}Detecting IP Address${NC}"
if [ -z "$LIVE_SERVER_IP" ]; then
    echo -e "${CYAN}Need to set LIVE_SERVER_IP${NC}"
    echo -n "Enter the live servers IP: "
    read liveIP
    export LIVE_SERVER_IP=$liveIP
fi
echo -e "${GREEN}Detected IP Address is $LIVE_SERVER_IP${NC}"

echo -e "${BLUE}Detecting Port${NC}"
if [ -z "$LIVE_SERVER_PORT" ]; then
    echo -e "${CYAN}Need to set LIVE_SERVER_PORT${NC}"
    echo -n "Enter the live servers Port: "
    read livePort
    export LIVE_SERVER_PORT=$livePort
fi
echo -e "${GREEN}Detected Port is $LIVE_SERVER_PORT${NC}"

echo -e "${BLUE}Detecting Nginx Port${NC}"
if [ -z "$NGINX_LISTEN_PORT" ]; then
    echo -e "${CYAN}Need to set NGINX_LISTEN_PORT${NC}"
    echo -n "Enter the Nginx servers Port: "
    read nginxPort
    export NGINX_LISTEN_PORT=$nginxPort
fi
echo -e "${GREEN}Detected Port is $NGINX_LISTEN_PORT${NC}"

echo -e "${BLUE}Detecting Cache FQDN URL${NC}"
if [ -z "$CACHE_SERVER_FQDN_URL" ]; then
    echo -e "${CYAN}Need to set CACHE_SERVER_FQDN_URL${NC}"
    echo -n "Enter the Cache servers FQDN(url): "
    read cacheURL
    export CACHE_SERVER_FQDN_URL=$cacheURL
fi
echo -e "${GREEN}Detected URL is $CACHE_SERVER_FQDN_URL${NC}"

echo -e "${RED}Removing incompatible docker versions${NC}"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y; done >>setup.log 2>>error.log

echo -e "${GREEN}Adding Docker's official GPG key${NC} if it seems to lock up here type a 'y' and hit enter"
sudo rm /etc/apt/keyrings/docker.gpg >>setup.log 2>>error.log
sudo apt-get update >>setup.log 2>>error.log
sudo apt-get install ca-certificates curl gnupg -y >>setup.log 2>>error.log
sudo install -m 0755 -d /etc/apt/keyrings >>setup.log 2>>error.log
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg >>setup.log 2>>error.log
sudo chmod a+r /etc/apt/keyrings/docker.gpg >>setup.log 2>>error.log

echo -e "${GREEN}Installing docker and other needed Repositories${NC}"
sudo curl -sSL https://get.docker.com/ | CHANNEL=stable bash >>setup.log 2>>error.log

echo -e "${BLUE}Enabling Docker Service${NC}"
sudo systemctl enable --now docker >>setup.log 2>>error.log
export GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"

echo -e "${GREEN}Setting nginx.conf values${NC}"
sed -i "s/__LIVE_SERVER_IP__/$LIVE_SERVER_IP/g" files/nginx.conf >>setup.log 2>>error.log
sed -i "s/__LIVE_SERVER_PORT__/$LIVE_SERVER_PORT/g" files/nginx.conf >>setup.log 2>>error.log

echo -e "${GREEN}Setting docker-compose.yaml values${NC}"
sed -i "s/__LIVE_SERVER_IP__/$LIVE_SERVER_IP/g" docker-compose.yml >>setup.log 2>>error.log
sed -i "s/__LIVE_SERVER_PORT__/$LIVE_SERVER_PORT/g" docker-compose.yml >>setup.log 2>>error.log
sed -i "s/__NGINX_LISTEN_PORT__/$NGINX_LISTEN_PORT/g" docker-compose.yml >>setup.log 2>>error.log
sed -i "s/__CACHE_SERVER_FQDN_URL__/$CACHE_SERVER_FQDN_URL/g" docker-compose.yml >>setup.log 2>>error.log

echo -e "${GREEN}Setting sites-availble.conf values${NC}"
sed -i "s/__LIVE_SERVER_IP__/$LIVE_SERVER_IP/g" files/sites-available.conf >>setup.log 2>>error.log
sed -i "s/__LIVE_SERVER_PORT__/$LIVE_SERVER_PORT/g" files/sites-available.conf >>setup.log 2>>error.log
sed -i "s/__NGINX_LISTEN_PORT__/$NGINX_LISTEN_PORT/g" files/sites-available.conf >>setup.log 2>>error.log
sed -i "s/__CACHE_SERVER_FQDN_URL__/$CACHE_SERVER_FQDN_URL/g" files/sites-available.conf >>setup.log 2>>error.log

echo -e "${BLUE}Adding user to docker group${NC}"
sudo usermod -aG docker $USER >>setup.log 2>>error.log

echo -e "${BLUE}Adding NGINX and Certbot${NC}"
sudo apt install -y nginx
sudo apt install -y python3-certbot-nginx

echo -e "${BLUE}Setting up SSL${NC}"
sudo certbot certonly --nginx -d $CACHE_SERVER_FQDN_URL
sudo cp /etc/letsencrypt/live/$CACHE_SERVER_FQDN_URL/* certs/
systemctl stop nginx.service

echo -e "${BLUE}SSL Setup Complete${NC}"

echo -e "${GREEN}Setting sites-availble.conf values${NC}"
sed -i "s/listen 80 ;/#listen [::]:80 ;/g" files/sites-available.conf >>setup.log 2>>error.log
sed -i "s/listen \[::\]:80 ;/#listen \[::\]:80 ;/g" files/sites-available.conf >>setup.log 2>>error.log
sed -i "s/#listen 443 ssl http2;/listen 443 ssl http2;/g" files/sites-available.conf >>setup.log 2>>error.log
sed -i "s/#listen [::]:443 ssl http2;/listen [::]:443 ssl http2;/g" files/sites-available.conf >>setup.log 2>>error.log
sed -i "s/#ssl_certificate \/etc\/ssl\/cert.pem;/ssl_certificate \/etc\/ssl\/cert.pem;/g" files/sites-available.conf >>setup.log 2>>error.log
sed -i "s/#ssl_certificate_key \/etc\/ssl\/privkey.pem;/ssl_certificate_key \/etc\/ssl\/privkey.pem;/g" files/sites-available.conf >>setup.log 2>>error.log

echo -e "${BLUE}Starting caching container${NC}"
sudo docker compose up --build -d

echo -e "$GREEN}Installation has Completed${NC}"
echo -e "${BLUE}If any build errors they will be listed below:${RED}"
cat error.log
echo -e "${BLUE}End of errors${NC}"

echo -e "${BLUE}Waiting for container to report Healthy"
while [ "`docker inspect -f {{.State.Health.Status}} legendscaching-cache-1`" != "healthy" ]; do     sleep 2; done

echo -e "${BLUE}Printing Docker Status${NC}"
sudo docker ps

echo -e "${BLUE}Printing Docker Logs${NC}"
sudo docker logs legendscaching-cache-1

echo -e "${BLUE}You can check the site at https://$CACHE_SERVER_FQDN_URL${NC}"
