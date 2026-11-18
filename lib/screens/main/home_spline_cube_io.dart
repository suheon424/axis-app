import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// iOS·Android: 웹뷰에 Spline 공개 링크를 그대로 띄운다. 그 밖의 플랫폼(데스크톱·테스트)은 null을
/// 돌려주어 큐브 그림이 그대로 보이게 한다.
Widget? buildSplineScene({
  required String url,
  required VoidCallback onLoaded,
  required ValueChanged<bool> onPressChanged,
}) {
  if (!onMobileDevice) return null;
  return _SplineWebView(url: url, onLoaded: onLoaded, onPressChanged: onPressChanged);
}

/// iOS·Android 기기에서 돌고 있는지(테스트·데스크톱은 false).
bool get onMobileDevice => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// 앱 전체에서 하나만 쓰는 Spline 웹뷰.
///
/// 예전에는 달성률 화면을 열 때마다 웹뷰를 새로 만들어 장면(3D 파일·런타임)을 처음부터 받고
/// 그렸기 때문에 큐브가 늦게 떴다. 이제 앱이 뜨고 조금 뒤 한 번만 받아 두고, 화면을 다시 열면
/// 이미 그려진 같은 웹뷰를 붙이기만 해서 바로 보인다.
class _SharedScene {
  _SharedScene._();

  static WebViewController? controller;
  static String? url;

  /// 페이지를 다 받고 장면이 그려질 시간까지 지났는지.
  static final ready = ValueNotifier(false);

  /// 지금 화면의 손가락 버튼 숨김 콜백.
  static ValueChanged<bool>? onPress;

  static const _pressScript = '''
(function(){
  if (window.__axisPress) return; window.__axisPress = true;
  var down = false;
  function send(v){ if (down === v) return; down = v; try { AxisPress.postMessage(v ? 'down' : 'up'); } catch (e) {} }
  ['pointerdown','touchstart','mousedown'].forEach(function(t){ window.addEventListener(t, function(){ send(true); }, {capture:true, passive:true}); });
  ['pointerup','pointercancel','touchend','touchcancel','mouseup'].forEach(function(t){ window.addEventListener(t, function(e){ if (e.touches && e.touches.length) return; send(false); }, {capture:true, passive:true}); });
})();
''';

  static Timer? _reveal;

  static WebViewController ensure(String u) {
    final c = controller;
    if (c != null && url == u) return c;
    url = u;
    ready.value = false;
    final created = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      // 웹뷰가 터치를 바로 가져가 Flutter 쪽 Listener가 손 뗌을 못 받을 수 있어서,
      // 페이지 안에서 누름/뗌을 직접 알려 받는다(손가락 버튼 숨김·다시 보임).
      ..addJavaScriptChannel('AxisPress', onMessageReceived: (m) => onPress?.call(m.message == 'down'))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            controller?.runJavaScript(_pressScript).catchError((_) {});
            _reveal?.cancel();
            // 페이지를 다 받은 뒤에도 장면이 그려지기까지 잠깐 걸린다.
            _reveal = Timer(const Duration(milliseconds: 1200), () => ready.value = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(u));
    controller = created;
    return created;
  }
}

Timer? _warmTimer;

/// 앱이 뜬 뒤 공용 웹뷰로 Spline 장면을 미리 받아 그려 둔다.
void prewarmSplineScene(String url) {
  if (!onMobileDevice || _warmTimer != null) return;
  // 첫 화면 그리기와 겹치지 않게 조금 뒤에 시작한다.
  _warmTimer = Timer(const Duration(milliseconds: 1500), () => _SharedScene.ensure(url));
}

class _SplineWebView extends StatefulWidget {
  const _SplineWebView({required this.url, required this.onLoaded, required this.onPressChanged});

  final String url;
  final VoidCallback onLoaded;
  final ValueChanged<bool> onPressChanged;

  @override
  State<_SplineWebView> createState() => _SplineWebViewState();
}

class _SplineWebViewState extends State<_SplineWebView> {
  late final WebViewController _controller = _SharedScene.ensure(widget.url);
  Timer? _loaded;

  @override
  void initState() {
    super.initState();
    _SharedScene.onPress = widget.onPressChanged;
    _SharedScene.ready.addListener(_onReady);
    _onReady();
  }

  void _onReady() {
    if (!_SharedScene.ready.value) return;
    // 웹뷰가 서서히 보이는 동안(300ms) 기다렸다가 손가락 버튼을 보인다.
    _loaded?.cancel();
    _loaded = Timer(const Duration(milliseconds: 300), () {
      if (mounted) widget.onLoaded();
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _loaded?.cancel();
    _SharedScene.ready.removeListener(_onReady);
    if (_SharedScene.onPress == widget.onPressChanged) _SharedScene.onPress = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 누름(손가락 버튼 숨김)은 SplineCube의 Listener와 페이지 안 스크립트가 함께 알려 준다.
    // 드래그는 웹뷰가 바로 받아 큐브를 돌린다. 장면 위치는 SplineCube가 웹과 같이 40 내린다.
    return AnimatedOpacity(
      opacity: _SharedScene.ready.value ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: WebViewWidget(
        controller: _controller,
        gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
      ),
    );
  }
}
