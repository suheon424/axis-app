import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'home_spline_viewer_html.dart';

/// iOS·Android: 웹뷰에 `<spline-viewer>` HTML을 띄운다. 그 밖의 플랫폼(데스크톱·테스트)은 null을
/// 돌려주어 큐브 그림이 그대로 보이게 한다.
Widget? buildSplineScene({
  required String url,
  required VoidCallback onLoaded,
  required ValueChanged<bool> onPressChanged,
}) {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return null;
  return _SplineWebView(url: url, onLoaded: onLoaded);
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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'SplineBridge',
        onMessageReceived: (m) {
          if (m.message == 'loaded') widget.onLoaded();
        },
      )
      ..loadHtmlString(splineViewerHtml(widget.url), baseUrl: 'https://localhost/');
  }

  @override
  Widget build(BuildContext context) {
    // 누름(손가락 버튼 숨김)은 SplineCube의 Listener가 받는다. 드래그는 웹뷰가 바로 받아 큐브를 돌린다.
    return WebViewWidget(
      controller: _controller,
      gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
    );
  }
}

