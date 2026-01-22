FROM alpine:3.23.2

RUN apk update && apk add --no-cache \
	mariadb=11.4.9-r0 \
	mariadb-client=11.4.9-r0 \
	mariadb-server-utils=11.4.9-r0

COPY tools/init-mariadb.sh /init-mariadb.sh

RUN chmod +x /init-mariadb.sh

ENTRYPOINT [ "/init-mariadb.sh" ]

EXPOSE 3306