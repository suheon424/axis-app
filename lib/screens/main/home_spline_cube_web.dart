import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// 웹: Spline 공개 링크를 iframe으로 HtmlElementView에 띄운다.
Widget? buildSplineScene({
  required String url,
  required VoidCallback onLoaded,
  required ValueChanged<bool> onPressChanged,
}) {
  return _SplineHtmlView(url: url, onLoaded: onLoaded, onPressChanged: onPressChanged);
}

/// 웹은 web/index.html이 앱이 뜬 뒤 장면을 미리 받아 둔다.
void prewarmSplineScene(String url) {}

bool get onMobileDevice => false;

int _nextViewId = 0;

class _SplineHtmlView extends StatefulWidget {
  const _SplineHtmlView({required this.url, required this.onLoaded, required this.onPressChanged});

  final String url;
  final VoidCallback onLoaded;
  final ValueChanged<bool> onPressChanged;

  @override
  State<_SplineHtmlView> createState() => _SplineHtmlViewState();
}

class _SplineHtmlViewState extends State<_SplineHtmlView> {
  late final String _viewType = 'axis-spline-viewer-${_nextViewId++}';

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) => _createElement());
  }

  web.HTMLElement _createElement() {
    // Spline 공개 링크를 iframe으로 그대로 띄운다(Spline이 준 임베드 코드와 같다).
    final el = web.document.createElement('iframe') as web.HTMLIFrameElement
      ..src = widget.url
      ..setAttribute('frameborder', '0')
      ..setAttribute('allow', 'autoplay; fullscreen; xr-spatial-tracking')
      ..setAttribute('loading', 'eager');
    el.style
      ..display = 'block'
      ..width = '100%'
      ..height = '100%'
      ..border = '0'
      ..background = 'transparent'
      // 장면이 다 그려지기 전의 빈 화면이 보이지 않게, 불러온 뒤 잠깐 기다렸다가 서서히 보인다.
      // 그동안은 SplineCube가 같은 자리에 큐브 그림을 먼저 보여 준다.
      ..opacity = '0'
      ..transition = 'opacity 300ms ease-out';
    el.addEventListener(
      'load',
      ((web.Event _) {
        _reveal?.cancel();
        _reveal = Timer(const Duration(milliseconds: 600), () {
          el.style.opacity = '1';
          _reveal = Timer(const Duration(milliseconds: 300), () {
            if (mounted) widget.onLoaded();
          });
        });
      }).toJS,
    );
    // iframe 안의 터치는 이 문서로 오지 않는다. iframe을 누르면 창이 포커스를 잃으므로(blur)
    // 그때 손가락 버튼을 숨기고, 잠시 뒤 다시 보이게 한 다음 포커스를 되찾아 다음 누름도 알아챈다.
    final blur = ((web.Event _) {
      if (!mounted || web.document.activeElement != el) return;
      widget.onPressChanged(true);
      _refocus?.cancel();
      _refocus = Timer(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        widget.onPressChanged(false);
        web.window.focus();
      });
    }).toJS;
    _blur = blur;
    web.window.addEventListener('blur', blur);
    return el;
  }

  Timer? _refocus;
  Timer? _reveal;
  JSFunction? _blur;

  @override
  void dispose() {
    _refocus?.cancel();
    _reveal?.cancel();
    final b = _blur;
    if (b != null) web.window.removeEventListener('blur', b);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
