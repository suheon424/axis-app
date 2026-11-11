import 'dart:js_interop';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

final ValueNotifier<double> _inset = () {
  final n = ValueNotifier<double>(0);
  final vv = web.window.visualViewport;
  if (vv == null) return n;
  void update(web.Event _) {
    // 키패드에 영향받지 않는 레이아웃 높이(사파리는 innerHeight가 키패드만큼 줄어들 때도 있다).
    final full = math.max(web.window.innerHeight, web.document.documentElement?.clientHeight ?? 0).toDouble();
    final visible = vv.height + vv.offsetTop;
    n.value = math.max(0, full - visible).roundToDouble();
    // 사파리가 입력칸을 보이게 하려고 페이지를 밀어 올리면 앱 전체가 위로 밀린다. 제자리로 돌려 둔다.
    if (web.window.scrollY != 0) web.window.scrollTo(0.toJS, 0);
  }

  vv.addEventListener('resize', update.toJS);
  vv.addEventListener('scroll', update.toJS);
  return n;
}();

ValueListenable<double> get browserKeyboardInset => _inset;
