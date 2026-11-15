# Use Debian 12 (Bookworm)
FROM debian:bookworm

# Install PHP-FPM and required PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-redis \
    curl \
    ca-certificates \
    tar \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on TCP port 9000
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Prepare WordPress directories
RUN mkdir -p /run/php /var/www/html

WORKDIR /var/www/html

# Copy the WordPress startup script
COPY tools/setup-wordpress.sh /usr/local/bin/setup-wordpress.sh
RUN chmod +x /usr/local/bin/setup-wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup-wordpress.sh"]