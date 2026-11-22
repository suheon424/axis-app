import 'package:flutter/widgets.dart';

/// 실제 앱에서 상단 상태바 자리를 인스타처럼 바탕색 그라데이션으로 덮는다.
/// 화면 내용이 상태바 아래로 지나가면 위로 갈수록 바탕색에 묻힌다. 화면의 [Stack] 맨 위에 둔다.
/// 테스트 링크(웹)는 상태바 자리를 앱이 그리지 않아 높이가 0이라 아무것도 그리지 않는다.
class StatusBarBlur extends StatelessWidget {
  const StatusBarBlur({super.key, required this.tint});

  /// 그라데이션 색(화면 바탕색).
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    if (top == 0) return const SizedBox.shrink();
    // 인스타처럼 상태바 자리는 바탕색에서 아래로 갈수록 투명해지는 그라데이션으로 덮는다(딱 끊기는 띠 없이).
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: top + 28,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tint.withValues(alpha: 0.95), tint.withValues(alpha: 0.8), tint.withValues(alpha: 0)],
              stops: [0, top / (top + 28) * 0.6, 1],
            ),
          ),
        ),
      ),
    );
  }
}
