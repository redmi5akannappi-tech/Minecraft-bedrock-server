#!/usr/bin/env python3
# simple always-200 health server
import http.server, socketserver, os
PORT = int(os.environ.get("FAKE_PORT", "8080"))
class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"ok\n")
if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Fake server listening on {PORT}")
        httpd.serve_forever()
