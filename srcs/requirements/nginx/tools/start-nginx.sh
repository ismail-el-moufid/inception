#!/bin/sh

DOMAIN_NAME="${DOMAIN_NAME:-localhost}"

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f "/etc/nginx/ssl/server.crt" ] || [ ! -f "/etc/nginx/ssl/server.key" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-subj "/CN=$DOMAIN_NAME" \
		-keyout "/etc/nginx/ssl/server.key" \
		-out "/etc/nginx/ssl/server.crt"
fi

# Start nginx
exec nginx -g "daemon off;"
