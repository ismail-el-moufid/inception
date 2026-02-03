#!/bin/sh

set -e

# Required env vars
required_vars="HOST_UID HOST_GID USERNAME PASSWORD"
for v in $required_vars; do
	if [ -z "$(eval "printf '%s' \"\$$v\"")" ]; then
		echo "$v is required" 1>&2
		exit 1
	fi
done

# create user if missing (match host UID/GID so volume ownership aligns)
if ! id -u "$USERNAME" >/dev/null 2>&1; then

	if ! grep -qE "^[^:]+:[^:]*:${HOST_GID}:" /etc/group 2>/dev/null; then
		addgroup -g "$HOST_GID" "$USERNAME"
	fi

	# create the user with the specified UID and primary group (the group name is the username)
	adduser -D -u "$HOST_UID" -G "$USERNAME" -h "/home/$USERNAME" -s /bin/ash "$USERNAME"
fi

# set password
echo "${USERNAME}:${PASSWORD}" | chpasswd

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
# -p 10000:10000 - Passive port range 10000-10100
# -U 022:022 - Umask 022 for files and directories
# -R - Disable chmod command
# -d -d - Verbose logging