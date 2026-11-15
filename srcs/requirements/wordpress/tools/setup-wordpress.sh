#!/bin/bash
set -e

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${WORDPRESS_URL:?WORDPRESS_URL is required}"
: "${REDIS_PASSWORD:?REDIS_PASSWORD is required}"

cd /var/www/html

# Wait for MariaDB to become ready
echo "Waiting for MariaDB..."

until php -r '
$db = @new mysqli(
    "mariadb",
    getenv("MYSQL_USER"),
    getenv("MYSQL_PASSWORD"),
    getenv("MYSQL_DATABASE"),
    3306
);
exit($db->connect_error ? 1 : 0);
' 2>/dev/null; do
    echo "MariaDB is not ready yet. Retrying in 2 seconds..."
    sleep 2
done

echo "MariaDB is ready!"

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

# Configure WordPress and Redis before WordPress initialization
php <<'PHP'
<?php
$file = "/var/www/html/wp-config.php";
$url = getenv("WORDPRESS_URL");
$password = getenv("REDIS_PASSWORD");

$content = file_get_contents($file);

if ($content === false) {
    fwrite(STDERR, "ERROR: Cannot read wp-config.php\n");
    exit(1);
}

$config = [
    "WP_HOME" => $url,
    "WP_SITEURL" => $url,
    "FS_METHOD" => "direct",
    "WP_REDIS_HOST" => "redis",
    "WP_REDIS_PORT" => 6379,
    "WP_REDIS_DATABASE" => 0,
    "WP_REDIS_PASSWORD" => $password
];

// Remove existing definitions so none remain after wp-settings.php
foreach (array_keys($config) as $name) {
    $pattern = '/^[ \t]*define\s*\(\s*[\'"]'
        . preg_quote($name, '/')
        . '[\'"]\s*,[^;]*\);\s*\r?\n/m';

    $content = preg_replace($pattern, '', $content);
}

// Build all definitions
$definitions = "";

foreach ($config as $name => $value) {
    $definitions .= "define("
        . var_export($name, true)
        . ", "
        . var_export($value, true)
        . ");\n";
}

// Find the WordPress initialization line
$marker = "require_once ABSPATH . 'wp-settings.php';";
$position = strpos($content, $marker);

if ($position === false) {
    fwrite(STDERR, "ERROR: Cannot find wp-settings.php initialization line\n");
    exit(1);
}

// Insert all definitions immediately before WordPress initialization
$content = substr_replace(
    $content,
    $definitions . "\n",
    $position,
    0
);

if (file_put_contents($file, $content) === false) {
    fwrite(STDERR, "ERROR: Cannot write wp-config.php\n");
    exit(1);
}
PHP

# Start PHP-FPM in the foreground
exec php-fpm8.2 -F
