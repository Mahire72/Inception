#!/bin/bash
set -e

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${WORDPRESS_URL:?WORDPRESS_URL is required}"

cd /var/www/html

# Download WordPress if it is not installed
if [ ! -f wp-load.php ]; then
    curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz --strip-components=1
    rm -f /tmp/wordpress.tar.gz
fi

# Create wp-config.php if it does not exist
if [ ! -f wp-config.php ]; then
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
    sed -i "s/localhost/mariadb/" wp-config.php
fi

# Validate the public website URL
case "$WORDPRESS_URL" in
    https://*) ;;
    *)
        echo "ERROR: WORDPRESS_URL must start with https://"
        exit 1
        ;;
esac

# Update or insert WordPress URL constants
php -r '
$file = "/var/www/html/wp-config.php";
$url = getenv("WORDPRESS_URL");

$content = file_get_contents($file);

foreach (["WP_HOME", "WP_SITEURL"] as $constant) {
    $definition = "define('\''" . $constant . "'\'', '\''" . $url . "'\'');";

    $pattern = "/define\s*\(\s*['\''\"]" . $constant . "['\''\"]\s*,\s*[^;]*\);/";

    if (preg_match($pattern, $content)) {
        $content = preg_replace($pattern, $definition, $content);
    } else {
        $marker = "/* Thats all, stop editing!";

        $position = strpos($content, "/* Thats all, stop editing!");
        if ($position === false) {
            $position = strpos($content, "/* That'\''s all, stop editing!");
        }

        if ($position === false) {
            fwrite(STDERR, "Cannot find wp-config.php insertion point\n");
            exit(1);
        }

        $content = substr_replace(
            $content,
            $definition . "\n",
            $position,
            0
        );
    }
}

file_put_contents($file, $content);
'

exec php-fpm8.2 -F
