FROM alpine:3.23.2

RUN apk update && apk add --no-cache redis=8.4.0-r0

COPY conf/redis.conf /etc/redis/redis.conf

CMD ["redis-server", "/etc/redis/redis.conf"]

EXPOSE 6379