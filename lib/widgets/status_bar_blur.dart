import 'dart:ui';

import 'package:flutter/widgets.dart';

/// 실제 앱에서 상단 상태바 자리를 인스타처럼 투명하게 두고 살짝 블러만 깐다.
/// 화면 내용이 상태바 아래로 지나가면 흐리게 비친다. 화면의 [Stack] 맨 위에 둔다.
/// 테스트 링크(웹)는 상태바 자리를 앱이 그리지 않아 높이가 0이라 아무것도 그리지 않는다.
class StatusBarBlur extends StatelessWidget {
  const StatusBarBlur({super.key, required this.tint});

  /// 블러 위에 얇게 덮는 색(화면 바탕색). 75% 불투명으로 깐다.
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    if (top == 0) return const SizedBox.shrink();
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: top,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: ColoredBox(color: tint.withValues(alpha: 0.75)),
        ),
      ),
    );
  }
}
