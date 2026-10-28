"""Vendor pinned ONNX Runtime Web assets and the existing backend model.

Run: python frontend/tool/vendor_audio_runtime.py
JS/MJS/WASM ship together; the app has no runtime CDN dependency.
"""
import base64
import hashlib
import io
import json
from pathlib import Path
import shutil
import tarfile
from urllib.request import urlopen

VERSION = '1.31.1'
ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'web' / 'vendor' / 'onnxruntime'
FILES = ['dist/ort.wasm.min.js', 'dist/ort-wasm-simd-threaded.mjs',
         'dist/ort-wasm-simd-threaded.wasm']


def main():
    with urlopen(f'https://registry.npmjs.org/onnxruntime-web/{VERSION}', timeout=30) as response:
        metadata = json.load(response)
    with urlopen(metadata['dist']['tarball'], timeout=60) as response:
        archive = response.read()
    expected = metadata['dist']['integrity']
    actual = 'sha512-' + base64.b64encode(hashlib.sha512(archive).digest()).decode()
    if actual != expected:
        raise RuntimeError('Runtime tarball integrity mismatch')
    DEST.mkdir(parents=True, exist_ok=True)
    checksums = {}
    with tarfile.open(fileobj=io.BytesIO(archive), mode='r:gz') as package:
        for name in FILES:
            source = package.extractfile('package/' + name)
            if source is None:
                raise RuntimeError(f'Missing runtime asset: {name}')
            data = source.read()
            (DEST / Path(name).name).write_bytes(data)
            checksums[Path(name).name] = hashlib.sha256(data).hexdigest()
    with urlopen(f'https://raw.githubusercontent.com/microsoft/onnxruntime/v{VERSION}/LICENSE', timeout=30) as response:
        license_text = response.read()
    (DEST / 'LICENSE').write_bytes(license_text)
    checksums['LICENSE'] = hashlib.sha256(license_text).hexdigest()
    model = ROOT / 'assets' / 'models' / 'yamnet.onnx'
    shutil.copyfile(ROOT.parent / 'backend' / 'app' / 'models' / 'yamnet.onnx', model)
    checksums['yamnet.onnx'] = hashlib.sha256(model.read_bytes()).hexdigest()
    (DEST / 'VERSION.json').write_text(json.dumps({
        'package': 'onnxruntime-web', 'version': VERSION,
        'npm_integrity': expected, 'sha256': checksums,
    }, indent=2) + '\n', encoding='utf-8')
    print(f'Vendored ONNX Runtime Web {VERSION} and YAMNet; verified npm integrity.')


if __name__ == '__main__':
    main()
