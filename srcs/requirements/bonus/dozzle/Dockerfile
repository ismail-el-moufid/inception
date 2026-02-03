FROM alpine:3.23.2 as builder

COPY tools/dozzle /dozzle

RUN chmod +x /dozzle

FROM scratch

COPY --from=builder /dozzle /dozzle

CMD ["/dozzle", "--addr", ":8081"]

EXPOSE 8081