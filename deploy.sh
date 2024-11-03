#!/bin/bash

domain_name="libertyrising.online"
REMOTE_USER="mmeade"
REMOTE_HOST="10.10.10.5"
REMOTE_PATH="/etc/nginx/conf.d/nextcloud_collabora.conf"

# Set an environment variable
ssh mmeade@10.10.10.5 "export domain_name=${domain_name}"
ssh mmeade@10.10.10.5 "mkdir -p /mnt/Pool1/TenantStorage/Support/nginx-data && mkdir -p /mnt/Pool1/TenantStorage/Support/letsencrypt && chmod -R 755 /mnt/Pool1/TenantStorage/Support/nginx-data /mnt/Pool1/TenantStorage/Support/letsencrypt"


# Use ssh with a heredoc to write multiple lines to the remote file
ssh ${REMOTE_USER}@${REMOTE_HOST} << EOF
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
EOF
