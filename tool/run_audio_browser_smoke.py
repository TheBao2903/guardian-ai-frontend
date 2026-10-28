"""Real headless browser + packaged YAMNet, no microphone or production API.

Verifies browser inference against the backend ONNX model and repeats with all
HTTP resource requests disabled. Run: python frontend/tool/run_audio_browser_smoke.py
Requires Python numpy/onnxruntime and Chrome/Edge (or CHROME_EXECUTABLE).
"""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import os
import shutil
import subprocess
import tempfile
import threading

import numpy as np
import onnxruntime as ort

ROOT = Path(__file__).resolve().parents[1]
PAGE = b'''<!doctype html><meta charset="utf-8"><script src="audio_classifier.js"></script>
<script>
(async () => {
  try {
    const start = performance.now();
    await guardianAudioClassifier.initialize();
    const loadMs = performance.now() - start;
    const wave = new Float32Array(32000);
    for (let i = 0; i < wave.length; i++) wave[i] = Math.sin(i * 2 * Math.PI * 440 / 16000) * .1;
    const before = performance.now();
    const scores = await guardianAudioClassifier.classify(wave);
    const inferenceMs = performance.now() - before;
    await fetch('/offline', {method: 'POST'});
    const offline = await guardianAudioClassifier.classify(wave);
    if (offline.length !== 521 || scores.some((v,i) => Math.abs(v-offline[i]) > .00001)) {
      throw new Error('Offline inference differs');
    }
    guardianAudioClassifier.dispose();
    await fetch('/result', {method:'POST', body:JSON.stringify({scores:Array.from(scores), loadMs, inferenceMs, offline:true})});
  } catch (error) {
    await fetch('/result', {method:'POST', body:JSON.stringify({error:String(error)})});
  }
})();
</script>'''


def main():
    result = {}
    done = threading.Event()
    offline = threading.Event()
    resources = []

    class Handler(SimpleHTTPRequestHandler):
        extensions_map = {**SimpleHTTPRequestHandler.extensions_map,
                          '.mjs': 'application/javascript', '.wasm': 'application/wasm'}

        def log_message(self, *args):
            pass

        def do_GET(self):
            resources.append(self.path)
            if offline.is_set():
                self.send_error(503)
                return
            if self.path == '/':
                body = PAGE
            elif self.path == '/assets/assets/models/yamnet.onnx':
                body = (ROOT / 'assets/models/yamnet.onnx').read_bytes()
            else:
                return super().do_GET()
            self.send_response(200)
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_POST(self):
            if self.path == '/offline':
                offline.set()
            elif self.path == '/result':
                body = self.rfile.read(int(self.headers['Content-Length']))
                result.update(json.loads(body))
                done.set()
            else:
                self.send_error(404)
                return
            self.send_response(200)
            self.end_headers()

    browser = os.environ.get('CHROME_EXECUTABLE') or shutil.which('google-chrome') or shutil.which('chromium')
    if not browser:
        for candidate in ['C:/Program Files/Google/Chrome/Application/chrome.exe',
                          'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe']:
            if Path(candidate).is_file():
                browser = candidate
                break
    if not browser:
        raise SystemExit('Chrome/Edge not found; set CHROME_EXECUTABLE')
    server = ThreadingHTTPServer(('127.0.0.1', 0), partial(Handler, directory=str(ROOT / 'web')))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    try:
        with tempfile.TemporaryDirectory(prefix='guardian_audio_', ignore_cleanup_errors=True) as profile:
            process = subprocess.Popen([browser, '--headless', '--disable-gpu', '--no-first-run',
                '--no-default-browser-check', '--no-sandbox', '--user-data-dir=' + profile,
                f'http://127.0.0.1:{server.server_port}/'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
            try:
                if not done.wait(55):
                    raise RuntimeError(f'Browser timed out; resources requested: {resources}')
            finally:
                process.terminate()
                process.wait(timeout=10)
    finally:
        server.shutdown()
        server.server_close()
    if 'error' in result:
        raise RuntimeError(result['error'])
    wave = (np.sin(np.arange(32000) * 2 * np.pi * 440 / 16000) * .1).astype(np.float32)
    session = ort.InferenceSession(str(ROOT / 'assets/models/yamnet.onnx'))
    reference = session.run(None, {'waveform': wave})[0].max(axis=0)
    difference = float(np.max(np.abs(reference - np.array(result.pop('scores')))))
    assert difference < 0.0002, difference
    result['max_score_difference'] = difference
    result['external_requests'] = [r for r in resources if r.startswith('http')]
    assert result['external_requests'] == []
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
