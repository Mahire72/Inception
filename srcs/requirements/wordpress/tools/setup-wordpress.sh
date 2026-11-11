#!/bin/bash
set -e

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"

cd /var/www/html

# Download WordPress only if it isn't already installed
if [ ! -f wp-load.php ]; then
    curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz --strip-components=1
    rm /tmp/wordpress.tar.gz
fi

# Create the WordPress configuration if it doesn't exist
if [ ! -f wp-config.php ]; then
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
    sed -i "s/localhost/mariadb/" wp-config.php
fi

# Configure the WordPress website URL
if [ -n "${WORDPRESS_URL:-}" ]; then
    if ! grep -q "WP_HOME" wp-config.php; then
        sed -i "/\/\* That's all, stop editing!/i define('WP_HOME', '${WORDPRESS_URL}');" wp-config.php
    else
        sed -i "s|define('WP_HOME'.*|define('WP_HOME', '${WORDPRESS_URL}');|" wp-config.php
    fi

    if ! grep -q "WP_SITEURL" wp-config.php; then
        sed -i "/\/\* That's all, stop editing!/i define('WP_SITEURL', '${WORDPRESS_URL}');" wp-config.php
    else
        sed -i "s|define('WP_SITEURL'.*|define('WP_SITEURL', '${WORDPRESS_URL}');|" wp-config.php
    fi
fi

# Start PHP-FPM in the foreground
exec php-fpm8.2 -F
