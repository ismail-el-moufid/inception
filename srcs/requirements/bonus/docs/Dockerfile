FROM alpine:3.22.3

RUN mkdir -p /var/www/html
WORKDIR /var/www/html

RUN apk update && apk add --no-cache \
	python3=3.12.12-r0 \
	py3-jinja2=3.1.6-r0 \
	py3-waitress=3.0.2-r0 \
	py3-markdown=3.8-r0 \
	py3-paste=3.10.1-r0

COPY index.md ./index.md

COPY tools/run-static-server.py ./app.py
RUN chmod +x ./app.py

CMD ["python3", "app.py"]

EXPOSE 80
