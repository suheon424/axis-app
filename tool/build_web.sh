#!/usr/bin/env bash
# GitHub Pages용 웹 빌드. sw.js에 빌드 번호를 넣어야 배포할 때마다 휴대폰에 저장된 예전 파일이 바뀐다.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter build web --release --no-web-resources-cdn --base-href /axis-app/
build_id="$(git rev-parse --short HEAD)-$(date +%s)"
sed -i "s/__BUILD__/${build_id}/" build/web/sw.js
rm -f build/web/flutter_service_worker.js
echo "build/web ready (sw ${build_id})"
