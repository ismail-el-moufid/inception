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
ln -sf $(which php83) /usr/local/bin/php

# WordPress Setup
if ! su-exec wordpress:wordpress wp core is-installed; then

	echo "Setting up WordPress..."

	# Create admin and users
	su-exec wordpress:wordpress wp core install \
		--url="$SITE_URL" \
		--title="$SITE_TITLE" \
		--admin_user="$ADMIN_USER" \
		--admin_password="$ADMIN_PASSWORD" \
		--admin_email="$ADMIN_EMAIL" \
		--skip-email

	su-exec wordpress:wordpress wp user create "$NON_ADMIN_USER" "${NON_ADMIN_USER}@example.com" \
		--role=author \
		--user_pass="$NON_ADMIN_PASSWORD"
else
	echo "WordPress already set up. Skipping core install."
fi

# Redis Object Cache Setup
if ! su-exec wordpress:wordpress wp plugin is-installed redis-cache; then
	echo "Installing Redis Object Cache plugin..."
	su-exec wordpress:wordpress wp plugin install redis-cache --activate
else
	echo "Redis plugin already installed."
fi

# Check if object cache is enabled, if not enable it
if ! su-exec wordpress:wordpress wp redis status | grep -q "Status: Connected"; then
	echo "Enabling Redis Object Cache..."
	su-exec wordpress:wordpress wp redis enable
else
	echo "Redis Object Cache is already enabled and connected."
fi

# Remove inactive plugins
inactive_plugins=$(su-exec wordpress:wordpress wp plugin list --status=inactive --field=name || true)
if [ -n "$inactive_plugins" ]; then
	echo "Removing inactive plugins: $inactive_plugins"
	for plugin in $inactive_plugins; do
		su-exec wordpress:wordpress wp plugin delete "$plugin" || true
		done
	else
	echo "No inactive plugins to remove."
	fi

# Remove inactive themes
inactive_themes=$(su-exec wordpress:wordpress wp theme list --status=inactive --field=name || true)
if [ -n "$inactive_themes" ]; then
	echo "Removing inactive themes: $inactive_themes"
	for theme in $inactive_themes; do
		su-exec wordpress:wordpress wp theme delete "$theme" || true
	done
else
	echo "No inactive themes to remove."
fi

# start php-fpm
exec php-fpm83 -F