FROM alpine:3.22.3

RUN apk update && apk add --no-cache redis=8.0.4-r0

COPY conf/redis.conf /etc/redis/redis.conf

CMD ["redis-server", "/etc/redis/redis.conf"]

EXPOSE 6379