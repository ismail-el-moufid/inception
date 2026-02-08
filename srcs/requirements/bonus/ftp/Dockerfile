FROM alpine:3.22.3

RUN apk update && apk add --no-cache \
	pure-ftpd=1.0.52-r0

COPY tools/start-pure-ftpd.sh /start-pure-ftpd.sh
RUN chmod +x /start-pure-ftpd.sh

ENTRYPOINT ["/start-pure-ftpd.sh"]

EXPOSE 21 10000-10100