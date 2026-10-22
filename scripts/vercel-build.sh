#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Match the SDK used to verify this project locally.
FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.6}"
FLUTTER_SDK_PATH="${FLUTTER_SDK_PATH:-/tmp/guardian-flutter-${FLUTTER_VERSION}}"
export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true

if [[ ! -x "${FLUTTER_SDK_PATH}/bin/flutter" ]]; then
  git clone --depth 1 --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git "${FLUTTER_SDK_PATH}"
fi
export PATH="${FLUTTER_SDK_PATH}/bin:${PATH}"

# These are public frontend endpoints, matching the project's deployment.
# Vercel Environment Variables can override either endpoint.
API_BASE_URL="${API_BASE_URL:-https://guardian-ai-backend-srdi.onrender.com/api/v1}"
API_BASE_URL="${API_BASE_URL%/}"
if [[ "${API_BASE_URL}" != https://* ]]; then
  echo "API_BASE_URL must be a public HTTPS backend URL." >&2
  exit 1
fi
WS_BASE_URL="${WS_BASE_URL:-${API_BASE_URL/https:/wss:}/realtime/ws}"
if [[ "${WS_BASE_URL}" != wss://* ]]; then
  echo "WS_BASE_URL must use wss:// for the deployed website." >&2
  exit 1
fi

# pubspec.yaml lists .env as an asset, but Git deliberately excludes it.
# Supply an empty asset on Vercel; endpoints are compiled via --dart-define.
if [[ ! -f .env ]]; then
  touch .env
fi

flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release --base-href / \
  "--dart-define=API_BASE_URL=${API_BASE_URL}" \
  "--dart-define=WS_BASE_URL=${WS_BASE_URL}"

for artifact in index.html flutter_bootstrap.js main.dart.js; do
  if [[ ! -s "build/web/${artifact}" ]]; then
    echo "Missing Flutter web output: build/web/${artifact}" >&2
    exit 1
  fi
done
echo "Flutter web build complete: build/web"
