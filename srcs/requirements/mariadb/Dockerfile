FROM alpine:3.23.2

RUN apk update && apk add mariadb mariadb-client mariadb-server-utils

COPY tools/init-mariadb.sh /init-mariadb.sh

RUN chmod +x /init-mariadb.sh

ENTRYPOINT [ "/init-mariadb.sh" ]