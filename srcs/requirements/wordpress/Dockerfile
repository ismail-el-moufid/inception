FROM alpine:3.23.2

RUN apk update && apk add --no-cache \
	mariadb-client=11.4.9-r0 \
	php83=8.3.30-r0 \
	php83-fpm=8.3.30-r0 \
	php83-mysqli=8.3.30-r0 \
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
	php83-opcache=8.3.30-r0

WORKDIR /var/www/html/

COPY conf/wp-config.php /var/www/html/wp-config.php
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

RUN wget https://wordpress.org/wordpress-6.9.tar.gz && \
	tar -xzf wordpress-6.9.tar.gz && \
	rm wordpress-6.9.tar.gz && \
	mv wordpress/* . && rmdir wordpress && \
	adduser -D -H -u 1000 -s /bin/sh wordpress && \
	chown -R wordpress:wordpress /var/www/html

CMD ["php-fpm83", "-F"]

EXPOSE 9000