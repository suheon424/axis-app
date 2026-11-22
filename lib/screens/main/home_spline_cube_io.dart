import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'home_spline_cube.dart' show splineBoxHeight, splineSceneScale;

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

  /// 미리 그려 두기 중인지. iOS 웹뷰는 화면(창)에 붙어 있지 않으면 장면을 그리지 않고 멈춰 있어서,
  /// 달성률 화면을 처음 열 때 그제서야 3D를 준비하느라 늦게 뜬다. 앱이 뜬 직후 잠깐 앱 화면 뒤에
  /// 붙여 장면을 실제로 한 번 그려 둔다([SplineWarmHost]).
  static final warming = ValueNotifier(false);

  /// 달성률 화면에 붙어 있는 웹뷰 수. 같은 웹뷰를 두 곳에 동시에 붙이지 않게 뒤쪽 붙임은 뺀다.
  static final attached = ValueNotifier(0);

  static Timer? _stopWarm;

  static void _markReady() {
    _reveal?.cancel();
    ready.value = true;
    // 장면이 그려진 뒤 조금 더 돌려 두었다가(셰이더 준비) 뒤쪽 붙임을 뗀다.
    _stopWarm?.cancel();
    _stopWarm = Timer(const Duration(seconds: 3), () => warming.value = false);
  }

  /// 캔버스가 생기고 실제로 두 프레임이 그려지면 알린다(고정 대기 대신).
  static const _readyScript = '''
(function(){
  if (window.__axisReady) return; window.__axisReady = true;
  function check(){
    var c = document.querySelector('canvas');
    if (c && c.width > 0) {
      requestAnimationFrame(function(){ requestAnimationFrame(function(){ try { AxisReady.postMessage('1'); } catch (e) {} }); });
    } else { setTimeout(check, 50); }
  }
  check();
})();
''';

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
      ..addJavaScriptChannel('AxisReady', onMessageReceived: (_) => _markReady())
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            controller?.runJavaScript(_pressScript).catchError((_) {});
            controller?.runJavaScript(_readyScript).catchError((_) {});
            _reveal?.cancel();
            // 그려졌다는 알림이 오지 않을 때를 대비한 상한.
            _reveal = Timer(const Duration(milliseconds: 2500), _markReady);
          },
        ),
      )
      ..loadRequest(Uri.parse(u));
    controller = created;
    warming.value = true;
    return created;
  }
}

Timer? _warmTimer;

/// 앱이 뜬 뒤 공용 웹뷰로 Spline 장면을 미리 받아 그려 둔다.
void prewarmSplineScene(String url) {
  if (!onMobileDevice || _warmTimer != null) return;
  // 첫 화면이 그려진 직후 바로 받기 시작한다.
  _warmTimer = Timer(const Duration(milliseconds: 100), () => _SharedScene.ensure(url));
}

/// 앱 화면 뒤(가려진 곳)에 공용 웹뷰를 잠깐 붙여 장면을 미리 그려 둔다. 다 그려지면 스스로 빠진다.
class SplineWarmHost extends StatelessWidget {
  const SplineWarmHost({super.key});

  @override
  Widget build(BuildContext context) {
    if (!onMobileDevice) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: _SharedScene.warming,
      builder: (context, warming, _) => ValueListenableBuilder<int>(
        valueListenable: _SharedScene.attached,
        builder: (context, attached, _) {
          final c = _SharedScene.controller;
          if (!warming || attached > 0 || c == null) return const SizedBox.shrink();
          // 달성률 화면의 장면과 같은 크기(큐브 칸 = 화면 너비 × 260에 장면 배율을 곱한 크기)로 그려 둔다. 크기가 다르면
          // 화면에 붙일 때 장면이 크기를 다시 맞추지 못해 큐브가 크고 어긋나게 보인다.
          final w = MediaQuery.sizeOf(context).width * splineSceneScale;
          const h = splineBoxHeight * splineSceneScale;
          return ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: w,
              maxWidth: w,
              minHeight: h,
              maxHeight: h,
              child: IgnorePointer(child: WebViewWidget(controller: c)),
            ),
          );
        },
      ),
    );
  }
}

Widget splineWarmHost() => const SplineWarmHost();

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
  bool _counted = false;
  bool _canShow = false;

  @override
  void initState() {
    super.initState();
    _SharedScene.onPress = widget.onPressChanged;
    _SharedScene.ready.addListener(_onReady);
    // 뒤쪽 미리 그리기에서 먼저 떼어 낸 다음 프레임에 이 화면에 붙인다(같은 웹뷰를 두 곳에 붙이지 않게).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _SharedScene.attached.value++;
      _counted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _canShow = true);
        // 붙인 뒤 장면이 새 크기에 맞춰 다시 그려지게 알린다.
        for (final ms in const [50, 400]) {
          Timer(Duration(milliseconds: ms), () {
            if (mounted) _controller.runJavaScript("window.dispatchEvent(new Event('resize'))").catchError((_) {});
          });
        }
      });
    });
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
    if (_counted) WidgetsBinding.instance.addPostFrameCallback((_) => _SharedScene.attached.value--);
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
      child: _canShow
          ? WebViewWidget(
              controller: _controller,
              gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
            )
          : const SizedBox.expand(),
    );
  }
}
