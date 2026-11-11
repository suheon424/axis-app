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
      ..background = 'transparent';
    el.addEventListener(
      'load',
      ((web.Event _) {
        if (mounted) widget.onLoaded();
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
  JSFunction? _blur;

  @override
  void dispose() {
    _refocus?.cancel();
    final b = _blur;
    if (b != null) web.window.removeEventListener('blur', b);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
