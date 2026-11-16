#!/bin/bash
set -e

: "${FTP_USER:?FTP_USER is required}"
: "${FTP_PASSWORD:?FTP_PASSWORD is required}"

# Generate a self-signed TLS certificate
if [ ! -f /etc/ssl/certs/ftp.crt ] || [ ! -f /etc/ssl/private/ftp.key ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/ssl/private/ftp.key \
        -out /etc/ssl/certs/ftp.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=ftp"
fi

chmod 600 /etc/ssl/private/ftp.key

# Allow the nologin shell in PAM
grep -qxF /usr/sbin/nologin /etc/shells || echo /usr/sbin/nologin >> /etc/shells

# Create the shared WordPress group if needed
if ! getent group www-data >/dev/null; then
    groupadd -g 33 www-data
fi

# Create the FTP user
if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd --gid www-data \
        --home-dir /var/www/html \
        --no-create-home \
        --shell /usr/sbin/nologin "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

exec /usr/sbin/vsftpd /etc/vsftpd.conf

# he FTP user belongs to group www-data (GID 33).
# The user has no interactive shell.
# The password comes from your environment variables.
# The certificate is generated inside the container.
# We avoid changing ownership of your existing WordPress files.