import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'home_spline_viewer_html.dart';

/// 웹: `<spline-viewer>` 웹 컴포넌트를 HtmlElementView로 띄운다.
Widget? buildSplineScene({
  required String url,
  required VoidCallback onLoaded,
  required ValueChanged<bool> onPressChanged,
}) {
  return _SplineHtmlView(url: url, onLoaded: onLoaded, onPressChanged: onPressChanged);
}

bool _scriptInjected = false;

/// spline-viewer 스크립트를 문서에 한 번만 넣는다.
void _ensureViewerScript() {
  if (_scriptInjected) return;
  _scriptInjected = true;
  final script = web.document.createElement('script') as web.HTMLScriptElement
    ..type = 'module'
    ..src = splineViewerScript;
  web.document.head!.appendChild(script);
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
  JSFunction? _windowUp;

  @override
  void initState() {
    super.initState();
    _ensureViewerScript();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) => _createElement());
  }

  web.HTMLElement _createElement() {
    final el = web.document.createElement('spline-viewer') as web.HTMLElement
      ..setAttribute('url', widget.url)
      ..setAttribute('loading', 'eager')
      ..setAttribute('events-target', 'local')
      ..setAttribute('background', 'transparent');
    el.style
      ..display = 'block'
      ..width = '100%'
      ..height = '100%'
      ..background = 'transparent'
      ..setProperty('touch-action', 'none');

    el.addEventListener(
      'load-complete',
      ((web.Event _) {
        _hideLogo(el);
        Timer(const Duration(milliseconds: 500), () => _hideLogo(el));
        if (mounted) widget.onLoaded();
      }).toJS,
    );

    // 누르는 동안 손가락 버튼을 숨긴다. 이벤트는 Flutter가 아니라 이 DOM 요소로 온다.
    el.addEventListener(
      'pointerdown',
      ((web.Event _) {
        if (!mounted) return;
        widget.onPressChanged(true);
        _listenWindowUp();
      }).toJS,
    );
    void up(web.Event _) => _release();
    el.addEventListener('pointerup', up.toJS);
    el.addEventListener('pointercancel', up.toJS);
    return el;
  }

  /// 요소 밖에서 손을 떼도 다시 보이도록 window의 pointerup도 한 번 듣는다.
  void _listenWindowUp() {
    if (_windowUp != null) return;
    final fn = ((web.Event _) => _release()).toJS;
    _windowUp = fn;
    web.window.addEventListener('pointerup', fn);
    web.window.addEventListener('pointercancel', fn);
  }

  void _release() {
    final fn = _windowUp;
    if (fn != null) {
      web.window.removeEventListener('pointerup', fn);
      web.window.removeEventListener('pointercancel', fn);
      _windowUp = null;
    }
    if (mounted) widget.onPressChanged(false);
  }

  void _hideLogo(web.HTMLElement el) {
    try {
      el.shadowRoot?.querySelector('#logo')?.remove();
    } catch (_) {}
  }

  @override
  void dispose() {
    final fn = _windowUp;
    if (fn != null) {
      web.window.removeEventListener('pointerup', fn);
      web.window.removeEventListener('pointercancel', fn);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
