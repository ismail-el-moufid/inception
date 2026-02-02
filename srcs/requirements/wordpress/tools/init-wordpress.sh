#!/bin/sh
set -e

# Required env vars
required_vars="HOST_UID HOST_GID ADMIN_USER ADMIN_PASSWORD ADMIN_EMAIL NON_ADMIN_USER NON_ADMIN_PASSWORD SITE_URL SITE_TITLE DB_NAME DB_USER DB_PASSWORD DB_HOST"
for v in $required_vars; do
	if [ -z "$(eval "printf '%s' \"\$$v\"")" ]; then
		echo "$v is required" 1>&2
		exit 1
	fi
done

# Validate ADMIN_USER does not contain "admin"
if echo "$ADMIN_USER" | grep -qi "admin"; then
	echo "ERROR: ADMIN_USER cannot contain 'admin'" 1>&2
	exit 1
fi

# Create user and group
addgroup -g "${HOST_GID}" wordpress_group
adduser -D -u "${HOST_UID}" -G wordpress_group -h "/var/www/html" -s /bin/ash wordpress_user

if [ ! -d /var/www/html/wp-admin ]; then
	echo "WordPress not found, installing..."

	# Give ownership of /var/www/html and all its content to the wordpress user
	chown -R ${HOST_UID}:${HOST_GID} /var/www/html

	# Extract WordPress
	su-exec ${HOST_UID}:${HOST_GID} tar -xzf /var/www/html/wordpress.tar.gz -C /var/www/html --strip-components=1

	# Remove the tar file
    rm -f /var/www/html/wordpress.tar.gz
else
	echo "WordPress found, skipping installation."
fi

# Symlink php83 to php for wp
ln -sf "$(which php83)" /usr/local/bin/php

# helper to run wp as the wordpress user
wp()
{
	su-exec ${HOST_UID}:${HOST_GID} wp --path="/var/www/html" "$@"
}

# WordPress Setup
if ! wp core is-installed >/dev/null 2>&1; then
	wp core install \
		--url="$SITE_URL" \
		--title="$SITE_TITLE" \
		--admin_user="$ADMIN_USER" \
		--admin_password="$ADMIN_PASSWORD" \
		--admin_email="$ADMIN_EMAIL" \
		--skip-email

	wp user create "$NON_ADMIN_USER" "${NON_ADMIN_USER}@example.com" \
		--role=author \
		--user_pass="$NON_ADMIN_PASSWORD"
fi

# Redis Cache Setup
if ! wp plugin is-installed redis-cache >/dev/null 2>&1; then
	wp plugin install redis-cache --activate
fi
# Attempt to enable redis
wp redis enable >/dev/null 2>&1

# Remove inactive plugins/themes
for type in plugin theme; do
	items=$(wp "$type" list --status=inactive --field=name 2>/dev/null)
	if [ -n "$items" ]; then
		for item in $items; do
			wp "$type" delete "$item" >/dev/null 2>&1
		done
	fi
done

# start php-fpm
exec php-fpm83 -F