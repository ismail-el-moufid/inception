FROM alpine:3.22.3

RUN apk update && apk add --no-cache \
	php83=8.3.29-r0 \
	php83-opcache=8.3.29-r0 \
	php83-phar=8.3.29-r0 \
	php83-session=8.3.29-r0 \
	php83-mysqli=8.3.29-r0

WORKDIR /var/www/html

RUN wget -q -O adminer.php https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.php

CMD ["php83", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]

EXPOSE 8080