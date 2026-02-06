#!/usr/bin/env python3

# Minimal WSGI app to render index.md to HTML using jinja2.Template
import markdown
from jinja2 import Template
from waitress import serve
from paste.translogger import TransLogger

# Function to read index.md, convert to HTML, and wrap in a simple template
def render_md(path):
	with open(path, 'r', encoding='utf-8') as f:
		text = f.read()
	html = markdown.markdown(text, extensions=['fenced_code', 'tables', 'toc'])
	template = Template(
		'<!doctype html><html><head><meta charset="utf-8">'
		'<meta name="viewport" content="width=device-width,initial-scale=1">'
		'<style>body{font-family:Inter,Segoe UI,Arial,Helvetica,sans-serif;margin:2rem;}'
		'pre{background:#f6f8fa;padding:1rem;border-radius:6px;overflow:auto}</style>'
		'<title>Docs</title></head><body>{{ content }}</body></html>'
	)
	return template.render(content=html)

# WSGI app to serve the rendered HTML
def app(environ, start_response):
	path = environ.get('PATH_INFO', '/')
	if path == '/':
		body = render_md('index.md').encode('utf-8')
		start_response('200 OK', [
			('Content-Type', 'text/html; charset=utf-8'),
			('Content-Length', str(len(body)))
		])
		return [body]
	start_response('404 Not Found', [('Content-Type', 'text/plain; charset=utf-8')])
	return [b'Not found']

# Run the server on port 80, logging requests to the console
if __name__ == '__main__':
	print("Starting static server on http://0.0.0.0:80")
	serve(TransLogger(app, setup_console_handler=False), host='0.0.0.0', port=80)