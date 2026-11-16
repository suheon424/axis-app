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
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return null;
  return _SplineWebView(url: url, onLoaded: onLoaded);
}

/// 앱이 뜬 뒤 보이지 않는 웹뷰로 Spline 장면을 한 번 받아 둔다. 받은 파일이 기기에 남아
/// 홈 달성률 화면에서 큐브가 빨리 뜬다. 30초 뒤 웹뷰는 버린다.
WebViewController? _warm;
Timer? _warmTimer;

void prewarmSplineScene(String url) {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS) || _warmTimer != null) return;
  // 첫 화면 그리기와 겹치지 않게 2초 뒤에 시작한다.
  _warmTimer = Timer(const Duration(seconds: 2), () {
    _warm = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
    _warmTimer = Timer(const Duration(seconds: 30), () {
      _warm?.loadRequest(Uri.parse('about:blank'));
      _warm = null;
    });
  });
}

class _SplineWebView extends StatefulWidget {
  const _SplineWebView({required this.url, required this.onLoaded});

  final String url;
  final VoidCallback onLoaded;

  @override
  State<_SplineWebView> createState() => _SplineWebViewState();
}

class _SplineWebViewState extends State<_SplineWebView> {
  late final WebViewController _controller;

  /// 페이지를 다 받은 뒤에도 장면이 그려지기까지 잠깐 걸린다. 그동안은 웹뷰를 숨겨 두고
  /// SplineCube가 같은 자리에 큐브 그림을 보여 준다.
  bool _ready = false;
  Timer? _reveal;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) => _onPageFinished()))
      ..loadRequest(Uri.parse(widget.url));
  }

  void _onPageFinished() {
    _reveal?.cancel();
    _reveal = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _ready = true);
      // 웹뷰가 서서히 보이는 동안(300ms) 그림을 남겨 두었다가 치운다.
      _reveal = Timer(const Duration(milliseconds: 300), () {
        if (mounted) widget.onLoaded();
      });
    });
  }

  @override
  void dispose() {
    _reveal?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 누름(손가락 버튼 숨김)은 SplineCube의 Listener가 받는다. 드래그는 웹뷰가 바로 받아 큐브를 돌린다.
    // 장면 위치는 SplineCube가 웹과 같이 40 내린다.
    return AnimatedOpacity(
      opacity: _ready ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: WebViewWidget(
        controller: _controller,
        gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
      ),
    );
  }
}
