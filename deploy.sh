#!/bin/bash

domain_name="libertyrising.online"
REMOTE_PATH="/mnt/storage/letsencrypt/nextcloud_collabora.conf"

sudo mkdir -p /mnt/storage
sudo mount -t nfs -o rw,vers=4 10.10.10.5:/mnt/Pool1/TenantStorage/Support /mnt/storage


# Create necessary directories locally on the Docker host
sudo mkdir -p /mnt/storage/nginx-data
sudo mkdir -p /mnt/storage/letsencrypt
sudo chmod -R 755 /mnt/storage/nginx-data /mnt/storage/letsencrypt

# Write multiple lines to the conf.d file directly on the Docker host
cat << END_CONF > ${REMOTE_PATH}
# Nextcloud server block
server {
    listen 443 ssl;
    server_name nextcloud.${domain_name};

    ssl_certificate /etc/letsencrypt/live/nextcloud.${domain_name}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/nextcloud.${domain_name}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/nextcloud.${domain_name}/chain.pem;

    location / {
        proxy_pass http://nextcloud:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# Collabora server block
server {
    listen 443 ssl;
    server_name collabora.${domain_name};

    ssl_certificate /etc/letsencrypt/live/collabora.${domain_name}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/collabora.${domain_name}/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/collabora.${domain_name}/chain.pem;

    location / {
        proxy_pass http://collabora:9980;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
END_CONF
