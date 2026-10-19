/// `<spline-viewer>` 웹 컴포넌트 스크립트(버전 고정).
const splineViewerScript = 'https://unpkg.com/@splinetool/viewer@2.0.64/build/spline-viewer.js';

/// "Built with Spline" 표시를 숨기는 스크립트. `axisHideSplineLogo(viewer)`를 전역에 만든다.
/// 표시는 두 군데에 있다: 그림자 DOM의 `#logo`, 그리고 WebGL로 캔버스에 그리는 워터마크.
const splineHideLogoScript = r'''
window.axisHideSplineLogo = function (v) {
  try {
    var sr = v.shadowRoot;
    if (sr && !sr.getElementById('axis-nologo')) {
      var s = document.createElement('style');
      s.id = 'axis-nologo';
      s.textContent = '#logo{display:none!important;visibility:hidden!important}';
      sr.appendChild(s);
    }
    var app = v._spline;
    var p = app && app._renderer && app._renderer.pipeline;
    if (p && p.setWatermark) {
      p.setWatermark(null);
      if (p.updateRenderToScreen) p.updateRenderToScreen();
      if (app.requestRender) app.requestRender();
    }
  } catch (e) {}
};
''';

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
$splineHideLogoScript
  var viewer = document.getElementById('cube');
  function hideLogo() { window.axisHideSplineLogo(viewer); }
  hideLogo();
  viewer.addEventListener('load-complete', function () {
    hideLogo();
    [100, 500, 1500, 3000].forEach(function (ms) { setTimeout(hideLogo, ms); });
    if (window.SplineBridge) window.SplineBridge.postMessage('loaded');
  });
</script>
</body>
</html>
''';
}
