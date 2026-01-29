#!/bin/sh
set -e

# require env vars
: "${USERNAME:?USERNAME is required}"
: "${PASSWORD:?PASSWORD is required}"

# create user if missing (match host UID 1000 so volume ownership aligns)
if ! id -u "$USERNAME" >/dev/null 2>&1; then
	adduser -D -u 1000 -h "/home/$USERNAME" -s /bin/ash "$USERNAME"
fi

# set password
echo "${USERNAME}:${PASSWORD}" | chpasswd

# ensure ownership so user can read/write the shared volume
chown -R "$USERNAME":"$USERNAME" "/home/$USERNAME"

# start pure-ftpd
exec pure-ftpd \
	-P 127.0.0.1 \
	-S 21 \
	-c 10 \
	-C 5 \
	-E \
	-l unix \
	-A \
	-j \
	-p 10000:10100 \
	-U 022:022 \
	-R \
	-d -d

# -c 10 - Max 10 simultaneous clients
# -C 5 - Max 5 connections per IP
# -E - No anonymous access
# -l unix - Use Unix authentication
# -A - Chroot everyone to their home directory
# -j - Auto-create home directories if missing
# -p 10000:10100 - Passive port range 10000-10100
# -U 022:022 - Umask 022 for files and directories
# -R - Disable chmod command
# -d -d - Verbose logging