"""Run browser API checks without Flutter CanvasKit.

From frontend: python tool/run_flashlight_browser_smoke.py
Set CHROME_EXECUTABLE to override Chrome. No physical camera is used.
"""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import html
import os
import re
import shutil
import subprocess
import tempfile
import threading

root = Path(__file__).resolve().parents[1]
output = root / '.dart_tool' / 'flashlight_smoke'
output.mkdir(parents=True, exist_ok=True)
dart = shutil.which('dart') or shutil.which('dart.bat')
if not dart:
    raise SystemExit('Dart was not found on PATH')
subprocess.run([dart, 'compile', 'js', '-O1', 'tool/flashlight_browser_smoke.dart',
                '-o', str(output / 'main.js')], cwd=root, check=True)
(output / 'index.html').write_text(
    '<!doctype html><html><body><script defer src="main.js"></script></body></html>',
    encoding='utf-8')
browser = os.environ.get('CHROME_EXECUTABLE') or shutil.which('google-chrome') or shutil.which('chromium')
if not browser:
    for candidate in ['C:/Program Files/Google/Chrome/Application/chrome.exe',
                      'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe']:
        if Path(candidate).is_file():
            browser = candidate
            break
if not browser:
    raise SystemExit('Chrome was not found; set CHROME_EXECUTABLE')


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


server = ThreadingHTTPServer(('127.0.0.1', 0), partial(QuietHandler, directory=str(output)))
threading.Thread(target=server.serve_forever, daemon=True).start()
try:
    with tempfile.TemporaryDirectory(prefix='guardian_flash_smoke_', ignore_cleanup_errors=True) as profile:
        result = subprocess.run([
            browser, '--headless', '--disable-gpu', '--no-first-run',
            '--no-default-browser-check', '--no-sandbox',
            '--user-data-dir=' + profile, '--dump-dom', '--virtual-time-budget=10000',
            f'http://127.0.0.1:{server.server_port}/index.html',
        ], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=45)
        body = result.stdout
        match = re.search(r'<body[^>]*>(.*?)</body>', body, flags=re.S)
        print(html.unescape(re.sub('<[^>]+>', '', match.group(1) if match else body)))
        if 'data-result="passed"' not in body:
            print(result.stderr[-2000:])
            raise SystemExit(1)
finally:
    server.shutdown()
    server.server_close()
