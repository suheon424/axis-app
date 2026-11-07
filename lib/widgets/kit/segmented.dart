import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'shapes.dart';

/// Segmented/List Map(130:10156) · Segmented/Tab 3(130:10169): 회색 바탕(#E8ECF4) 위에
/// 사선으로 잘린 흰 표시가 선택된 탭으로 미끄러진다. 높이 40, 탭 글자 16 SemiBold(선택 파랑 / 나머지 gray06).
/// 탭 수는 2개 이상 아무 개수나 된다.
class AxisSegmentedTabs extends StatelessWidget {
  const AxisSegmentedTabs({super.key, required this.labels, required this.selected, required this.onChanged});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected.toDouble()),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => CustomPaint(
        painter: _IndicatorPainter(t: t, count: n),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selected,
                    label: labels[i],
                    excludeSemantics: true,
                    onTap: () => onChanged(i),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                        child: Text(
                          labels[i],
                          textAlign: TextAlign.center,
                          style: AxisText.button.copyWith(
                            color: Color.lerp(AppColors.brand, AppColors.gray06, (t - i).abs().clamp(0.0, 1.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  const _IndicatorPainter({required this.t, required this.count});

  final double t;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.segmentBg);
    final w = size.width / count, h = size.height;
    const s = 12.0; // 사선 폭의 절반
    final l = math.min(t, 1.0) * s;
    final r = math.min(count - 1 - t, 1.0) * s;
    final path = roundedPolygon(
      [Offset(t * w + l, 0), Offset((t + 1) * w - r, 0), Offset((t + 1) * w + r, h), Offset(t * w - l, h)],
      const [0, 0, 0, 0],
    );
    canvas.drawShadow(path, const Color(0x141F2129), 3, false);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_IndicatorPainter old) => old.t != t || old.count != count;
}

/// Segmented/Tab 2(130:9937): 사진·어두운 배경 위 반투명 알약(#454D58 50%) 두 칸 토글.
/// 선택된 칸은 흰 바탕 + 검정 13 Bold, 나머지는 흰 글자. 칸 사이는 사선.
class AxisPillSegment extends StatelessWidget {
  const AxisPillSegment({super.key, required this.labels, required this.selected, required this.onChanged});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0x80454D58), borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < n; i++)
            Semantics(
              button: true,
              selected: i == selected,
              label: labels[i],
              excludeSemantics: true,
              onTap: () => onChanged(i),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: CustomPaint(
                  painter: i == selected
                      ? PolygonPainter(
                          fill: Colors.white,
                          build: (sz) => _pillPiece(sz, first: i == 0, last: i == n - 1),
                        )
                      : null,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 71, minHeight: 30),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: i == selected ? AppColors.gray09 : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Path _pillPiece(Size size, {required bool first, required bool last}) {
    final w = size.width, h = size.height;
    const s = 6.0;
    final r = h / 2;
    return roundedPolygon(
      [Offset(first ? 0 : s, 0), Offset(last ? w : w + s, 0), Offset(last ? w : w - s, h), Offset(first ? 0 : -s, h)],
      [first ? r : 0, last ? r : 0, last ? r : 0, first ? r : 0],
    );
  }
}
