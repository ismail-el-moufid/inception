#!/bin/sh

DOMAIN_NAME="${DOMAIN_NAME:-localhost}"

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f "/etc/nginx/ssl/server.crt" ] || [ ! -f "/etc/nginx/ssl/server.key" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-subj "/CN=$DOMAIN_NAME" \
		-keyout "/etc/nginx/ssl/server.key" \
		-out "/etc/nginx/ssl/server.crt"
fi

# Replace placeholder in nginx configuration with actual domain name
sed -i "s|DOMAIN_NAME_PLACEHOLDER|${DOMAIN_NAME}|g" /etc/nginx/nginx.conf

# Start nginx
exec nginx
