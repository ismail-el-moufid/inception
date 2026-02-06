FROM alpine:3.23.2

RUN apk update && apk add --no-cache \
	su-exec=0.3-r0 \
	mariadb-client=11.4.9-r0 \
	php83=8.3.30-r0 \
	php83-phar=8.3.30-r0 \
	php83-fpm=8.3.30-r0 \
	php83-mysqli=8.3.30-r0 \
	php83-dom=8.3.30-r0 \
	php83-exif=8.3.30-r0 \
	php83-intl=8.3.30-r0 \
	php83-pecl-imagick=3.8.1-r0 \
	php83-pdo=8.3.30-r0 \
	php83-pdo_mysql=8.3.30-r0 \
	php83-openssl=8.3.30-r0 \
	php83-session=8.3.30-r0 \
	php83-gd=8.3.30-r0 \
	php83-curl=8.3.30-r0 \
	php83-xml=8.3.30-r0 \
	php83-mbstring=8.3.30-r0 \
	php83-zip=8.3.30-r0 \
	php83-fileinfo=8.3.30-r0 \
	php83-iconv=8.3.30-r0 \
	php83-opcache=8.3.30-r0 \
	php83-ctype=8.3.30-r0 \
	php83-pecl-redis=6.3.0-r0

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY conf/wp-config.php /var/www/html/wp-config.php

WORKDIR /var/www/html/

RUN wget -O /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar && \
	chmod +x /usr/local/bin/wp

RUN wget -O /var/www/html/wordpress.tar.gz https://wordpress.org/wordpress-6.9.1.tar.gz

COPY tools/init-wordpress.sh /init-wordpress.sh
RUN chmod +x /init-wordpress.sh

ENTRYPOINT ["/init-wordpress.sh"]

EXPOSE 9000