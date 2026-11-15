
#!/bin/bash
set -e

: "${FTP_USER:?FTP_USER is required}"
: "${FTP_PASSWORD:?FTP_PASSWORD is required}"

# Generate a self-signed TLS certificate if it does not exist
if [ ! -f /etc/ssl/certs/ftp.crt ] || [ ! -f /etc/ssl/private/ftp.key ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/ssl/private/ftp.key \
        -out /etc/ssl/certs/ftp.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=ftp"
fi

chmod 600 /etc/ssl/private/ftp.key

# Create the FTP user if it does not exist
if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd --home-dir /var/www/html --no-create-home \
        --shell /usr/sbin/nologin "$FTP_USER"
fi

# Set the FTP password
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Add FTP user to the WordPress web-server group
usermod -aG www-data "$FTP_USER"

# Start FTP server
exec /usr/sbin/vsftpd /etc/vsftpd.conf
