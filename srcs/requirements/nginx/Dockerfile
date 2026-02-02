FROM alpine:3.23.2

RUN apk update && apk add --no-cache \
	nginx=1.28.0-r8 \
	openssl=3.5.4-r0

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/start-nginx.sh /start-nginx.sh

RUN chmod +x /start-nginx.sh

ENTRYPOINT ["/start-nginx.sh"]

EXPOSE 443