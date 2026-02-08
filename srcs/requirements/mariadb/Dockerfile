FROM alpine:3.22.3

RUN apk update && apk add --no-cache \
	su-exec=0.2-r3 \
	mariadb=11.4.8-r0 \
	mariadb-client=11.4.8-r0 \
	mariadb-server-utils=11.4.8-r0

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
RUN chmod 644 /etc/my.cnf.d/mariadb-server.cnf

COPY tools/init-mariadb.sh /init-mariadb.sh
RUN chmod +x /init-mariadb.sh

ENTRYPOINT [ "/init-mariadb.sh" ]

EXPOSE 3306