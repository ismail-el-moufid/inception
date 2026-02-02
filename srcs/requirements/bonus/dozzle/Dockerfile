FROM alpine:3.23.2

COPY tools/dozzle /dozzle
RUN chmod +x /dozzle

CMD ["/dozzle", "--addr", ":8081"]

EXPOSE 8081