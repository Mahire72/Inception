# 1. choisir image de base
FROM debian:bookworm 
#utilise debian12

# 2. installer les dependances
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    ca-certificates \
    tar \
    && rm -rf /var/lib/apt/lists/*
# php8.2-fpm	Execute les scripts PHP grâce à PHP-FPM.
# php8.2-mysql	Permet à PHP de communiquer avec MariaDB/MySQL.
# curl telecharge des fichiers depuis internet.
# ca-certificates	Fournit les certificats des autorités de certification pour vérifier les connexions HTTPS.


RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /run/php /var/www/html

WORKDIR /var/www/html

COPY tools/setup-wordpress.sh /usr/local/bin/setup-wordpress.sh
RUN chmod +x /usr/local/bin/setup-wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup-wordpress.sh"]

