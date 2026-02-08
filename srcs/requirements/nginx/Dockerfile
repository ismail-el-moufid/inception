FROM alpine:3.22.3

RUN apk update && apk add --no-cache \
	nginx=1.28.2-r0 \
	openssl=3.5.5-r0

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/start-nginx.sh /start-nginx.sh

RUN chmod +x /start-nginx.sh

ENTRYPOINT ["/start-nginx.sh"]

EXPOSE 443