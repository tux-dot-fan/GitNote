#!/usr/bin/env python3
"""GitNote 站点预览服务器：
- 静态服务 _site 构建产物
- 请求 *.md 时，若存在同名 *.html 则 302 跳转过去（以 HTML 方式浏览）
- 无对应 .html 的 .md（无 frontmatter 的笔记）仍按原文返回
用法: python3 serve_site.py [端口]   （默认 4000）
"""
import http.server
import os
import socketserver
import sys
import urllib.parse

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '_site')
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else int(os.environ.get('PORT', 4000))


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = urllib.parse.unquote(parsed.path)
        if path.endswith(('.md', '.markdown')):
            rel = path.lstrip('/')
            html = os.path.splitext(rel)[0] + '.html'
            if os.path.isfile(os.path.join(ROOT, html)):
                target = '/' + urllib.parse.quote(html, safe='/') + ('#' + parsed.fragment if parsed.fragment else '')
                self.send_response(302)
                self.send_header('Location', target)
                self.end_headers()
                return
        super().do_GET()

    def do_HEAD(self):
        parsed = urllib.parse.urlparse(self.path)
        path = urllib.parse.unquote(parsed.path)
        if path.endswith(('.md', '.markdown')):
            html = os.path.splitext(path.lstrip('/'))[0] + '.html'
            if os.path.isfile(os.path.join(ROOT, html)):
                target = '/' + urllib.parse.quote(html, safe='/')
                self.send_response(302)
                self.send_header('Location', target)
                self.end_headers()
                return
        super().do_HEAD()

    def log_message(self, fmt, *args):
        sys.stderr.write('[%s] %s\n' % (self.log_date_time_string(), fmt % args))


class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


with Server(('127.0.0.1', PORT), Handler) as httpd:
    print(f'GitNote preview: http://127.0.0.1:{PORT}  ( *.md -> *.html 302 跳转 )')
    httpd.serve_forever()
