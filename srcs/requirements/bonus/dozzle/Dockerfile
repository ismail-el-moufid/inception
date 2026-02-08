FROM alpine:3.22.3 as builder

COPY tools/dozzle /dozzle

RUN chmod +x /dozzle

FROM scratch

COPY --from=builder /dozzle /dozzle

CMD ["/dozzle", "--addr", ":8081"]

EXPOSE 8081