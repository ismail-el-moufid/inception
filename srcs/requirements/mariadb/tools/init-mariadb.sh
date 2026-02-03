#!/bin/sh

# Exit on error
set -e

# Required env vars
required_vars="HOST_UID HOST_GID DB_NAME DB_USER DB_PASSWORD DB_ADMIN DB_ADMIN_CLIENT DB_ADMIN_PASSWORD DB_ROOT_PASSWORD DB_CLIENT"
for v in $required_vars; do
	if [ -z "$(eval "printf '%s' \"\$$v\"")" ]; then
		echo "$v is required" 1>&2
		exit 1
	fi
done

# Optional env vars with defaults
: "${DATA_DIR:=/var/lib/mysql}"
: "${SOCKET_DIR:=/var/lib/mysql/sockets}"
: "${SOCKET_NAME:=mysqld.sock}"

#Create user and group
if ! getent group mariadb_group >/dev/null 2>&1; then
	addgroup -g "$HOST_GID" mariadb_group
fi

if ! id -u mariadb_user >/dev/null 2>&1; then
	adduser -D -u "$HOST_UID" -G mariadb_group -h "/var/lib/mysql" -s /bin/ash mariadb_user
fi

# Ensure socket directory exists
su-exec "$HOST_UID":"$HOST_GID" mkdir -p "$SOCKET_DIR"

SOCKET="$SOCKET_DIR/$SOCKET_NAME"

# 1. Initialize system tables if they don't exist
if [ ! -d "$DATA_DIR/mysql" ]; then
	echo "Initializing MariaDB system tables..."

	output=$(su-exec "$HOST_UID":"$HOST_GID" mariadb-install-db --datadir="$DATA_DIR" --skip-test-db 2>&1) || {
		echo "Error initializing MariaDB system tables:" 1>&2
		echo "$output" 1>&2
		rm -rf "$DATA_DIR/mysql"
		exit 1
	}
	echo "MariaDB system tables initialized successfully."
fi

# 2. Create the database and user if they don't exist
su-exec "$HOST_UID":"$HOST_GID" mariadbd \
--datadir="$DATA_DIR" \
--socket="$SOCKET" \
--bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_CLIENT}' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_CLIENT}';
CREATE USER IF NOT EXISTS '${DB_ADMIN}'@'${DB_ADMIN_CLIENT}' IDENTIFIED BY '${DB_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_ADMIN}'@'${DB_ADMIN_CLIENT}' WITH GRANT OPTION;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "Database and user are set up."

# Run server as PID 1
echo "Starting MariaDB server..."
exec su-exec "$HOST_UID":"$HOST_GID" mariadbd \
	--datadir="$DATA_DIR" \
	--socket="$SOCKET" \
	--port=3306