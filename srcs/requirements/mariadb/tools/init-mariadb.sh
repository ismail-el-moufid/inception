#!/bin/sh

# Exit on error
set -e

# Required env vars
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${DB_ROOT_PASSWORD:?DB_ROOT_PASSWORD is required}"
: "${DB_CLIENT:?DB_CLIENT is required}"

# Optional env vars with defaults
: "${DATA_DIR:=/var/lib/mysql}"
: "${SOCKET_DIR:=/run/mysqld}"
: "${SOCKET_NAME:=mysqld.sock}"

# Ensure socket directory exists
mkdir -p "$SOCKET_DIR"
chown -R mysql:mysql "$SOCKET_DIR"

SOCKET="$SOCKET_DIR/$SOCKET_NAME"

# 1. Initialize system tables if they don't exist
if [ ! -d "$DATA_DIR/mysql" ]; then
	echo "Initializing MariaDB system tables..."

	# Ensure data directory permissions
	chown -R mysql:mysql "$DATA_DIR"
	chmod 777 "$DATA_DIR"

	output=$(mariadb-install-db --user=mysql --datadir="$DATA_DIR" --skip-test-db 2>&1)
	if [ $? -eq 0 ]; then
		echo "MariaDB system tables initialized successfully."
	else
		echo "Error initializing MariaDB system tables:"
		echo "$output"
		exit 1
	fi
fi

# 2. Create the database and user if they don't exist
mariadbd \
--user=mysql \
--datadir="$DATA_DIR" \
--socket="$SOCKET" \
--bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_CLIENT}' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_CLIENT}';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "Database and user are set up."

# Run server as PID 1
echo "Starting MariaDB server..."
exec mariadbd \
	--user=mysql \
	--datadir="$DATA_DIR" \
	--socket="$SOCKET"