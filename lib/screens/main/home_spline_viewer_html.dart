/// `<spline-viewer>` 웹 컴포넌트 스크립트(버전 고정).
const splineViewerScript = 'https://unpkg.com/@splinetool/viewer@2.0.64/build/spline-viewer.js';

/// 모바일 웹뷰에 띄우는 HTML. 배경은 투명, 장면을 다 불러오면 `SplineBridge`로 "loaded"를 보낸다.
String splineViewerHtml(String url) {
  final safeUrl = url.replaceAll('"', '%22');
  return '''
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
  html, body { margin: 0; padding: 0; width: 100%; height: 100%; background: transparent; overflow: hidden; }
  spline-viewer { display: block; width: 100%; height: 100%; background: transparent; }
</style>
<script type="module" src="$splineViewerScript"></script>
</head>
<body>
<spline-viewer id="cube" url="$safeUrl" loading="eager" events-target="local" background="transparent"></spline-viewer>
<script>
  var viewer = document.getElementById('cube');
  function hideLogo() {
    try { var logo = viewer.shadowRoot && viewer.shadowRoot.querySelector('#logo'); if (logo) logo.remove(); } catch (e) {}
  }
  viewer.addEventListener('load-complete', function () {
    hideLogo();
    setTimeout(hideLogo, 500);
    if (window.SplineBridge) window.SplineBridge.postMessage('loaded');
  });
</script>
</body>
</html>
''';
}
