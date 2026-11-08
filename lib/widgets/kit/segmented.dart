import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

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

/// Segmented/Tab 2(130:9937): 사진·어두운 배경 위 반투명 알약(#454D58 50%, 배경 흐림 5, 안쪽 여백 4) 두 칸 토글.
/// 칸은 70.5×30. 선택된 칸은 흰 조각(왼쪽 반원 + 오른쪽 사선, 옆 칸으로 6.7 넘어감) 위 #0F1014 13 Bold,
/// 나머지는 #BDC3D0. 두 번째 칸이 선택되면 조각을 180° 돌려 그린다(피그마 07_01 홈_달성률).
class AxisPillSegment extends StatelessWidget {
  const AxisPillSegment({super.key, required this.labels, required this.selected, required this.onChanged});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  static const _cellWidth = 70.5;
  static const _cellHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          padding: const EdgeInsets.all(4),
          color: const Color(0x80454D58),
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
                      painter: i == selected ? _PillPiecePainter(flipped: i == n - 1 && i > 0) : null,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: _cellWidth, minHeight: _cellHeight),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: i == selected ? AppColors.gray09 : AppColors.gray04,
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

/// Segmented/Tab 2의 흰 선택 조각(Union: 반원 끝 사각형 + Vector). 칸이 70.5보다 넓으면 평평한 부분만 늘린다.
class _PillPiecePainter extends CustomPainter {
  const _PillPiecePainter({required this.flipped});

  final bool flipped;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final ky = h / 30;
    final ox = 22.164764404296875 + (w - AxisPillSegment._cellWidth);
    Offset p(double x, double y) => Offset(ox + x, y * ky);
    final r = h / 2;
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(p(53.809, 0).dx, 0)
      ..cubicTo(p(54.766, 0).dx, 0, p(55.331, 1.087).dx, p(55.331, 1.087).dy, p(54.788, 1.882).dx, p(54.788, 1.882).dy)
      ..lineTo(p(36.984, 27.926).dx, p(36.984, 27.926).dy)
      ..cubicTo(p(36.097, 29.224).dx, p(36.097, 29.224).dy, p(34.630, 30).dx, h, p(33.064, 30).dx, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..close();
    if (flipped) {
      canvas.translate(w, h);
      canvas.rotate(math.pi);
    }
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_PillPiecePainter old) => old.flipped != flipped;
}
