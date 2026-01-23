#!/bin/sh

# Exit on error
set -e

# Required env vars
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${DB_CLIENT_HOST:?DB_CLIENT_HOST is required}"
: "${ROOT_PASSWORD:?ROOT_PASSWORD is required}"

# Optional env vars with defaults
: "${TIMEOUT:=30}"
: "${DATA_DIR:=/var/lib/mysql}"
: "${SOCKET_DIR:=/run/mysqld}"
: "${SOCKET_NAME:=mysqld.sock}"

# Ensure socket directory exists
mkdir -p "$SOCKET_DIR"
chown -R mysql:mysql "$SOCKET_DIR"

SOCKET="$SOCKET_DIR/$SOCKET_NAME"

# Check if already initialized
if [ ! -d "$DATA_DIR/mysql" ]; then
	echo "Initializing MariaDB..."

	output=$(mariadb-install-db --user=mysql --datadir="$DATA_DIR" 2>&1)
	if [ $? -eq 0 ]; then
		echo "mariadb-install-db completed successfully."
	else
		echo "ERROR: mariadb-install-db failed" 1>&2
		echo "$output" 1>&2
	fi

	# Init DB
	output=$( mariadbd \
		--datadir="$DATA_DIR" \
		--socket="$SOCKET" \
		--bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_CLIENT_HOST}' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_CLIENT_HOST}';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
	)

	if [ $? -eq 0 ]; then
		echo "MariaDB bootstrap setup completed successfully."
	else
		echo "ERROR: MariaDB bootstrap setup failed" 1>&2
		echo "$output" 1>&2
	fi
	echo "MariaDB initialization completed."
else
	echo "MariaDB already initialized. Skipping setup."
fi

# Run server as PID 1
exec mariadbd \
	--datadir="$DATA_DIR" \
	--socket="$SOCKET"