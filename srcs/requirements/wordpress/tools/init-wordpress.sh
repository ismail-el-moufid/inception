#!/bin/sh

# Exit on error
set -e

# Required env vars
: "${ADMIN_USER:?ADMIN_USER is required}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD is required}"
: "${ADMIN_EMAIL:?ADMIN_EMAIL is required}"
: "${NON_ADMIN_USER:?NON_ADMIN_USER is required}"
: "${NON_ADMIN_PASSWORD:?NON_ADMIN_PASSWORD is required}"
: "${SITE_URL:?SITE_URL is required}"
: "${SITE_TITLE:?SITE_TITLE is required}"
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${DB_HOST:?DB_HOST is required}"

# Validate ADMIN_USER does not contain "admin"
if echo "$ADMIN_USER" | grep -qi "admin"; then
	echo "ERROR: ADMIN_USER cannot contain 'admin'" 1>&2
	exit 1
fi

# Symlink php83 to php for wp
ln -Sf $(which php83) /usr/local/bin/php

if ! wp core is-installed --allow-root; then

	echo "Setting up WordPress..."

	# Create users
	wp core install --url="$SITE_URL" --title="$SITE_TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$ADMIN_EMAIL" --skip-email
	wp user create "$NON_ADMIN_USER" "${NON_ADMIN_USER}@example.com" --role=author --user_pass="$NON_ADMIN_PASSWORD"

else
	echo "WordPress already set up. Skipping setup."
fi

# start php-fpm
exec php-fpm83 -F