
FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer /run/php

RUN sed -i 's|^listen = .*|listen = 9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

RUN curl -fsSL https://www.adminer.org/latest.php \
    -o /var/www/adminer/index.php

RUN chown -R www-data:www-data /var/www/adminer

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
