import 'package:flutter/foundation.dart';

import 'browser_keyboard/browser_keyboard_io.dart'
    if (dart.library.js_interop) 'browser_keyboard/browser_keyboard_web.dart'
    as platform;

/// 폰 브라우저(특히 아이폰 사파리)에서 화면 키패드가 덮는 높이(논리 픽셀).
/// 사파리는 키패드가 떠도 앱에 아래 여백(viewInsets)을 알려주지 않을 때가 있어서,
/// 브라우저의 visualViewport를 직접 재서 알려 준다. 앱(네이티브)에서는 늘 0.
ValueListenable<double> get browserKeyboardInset => platform.browserKeyboardInset;
