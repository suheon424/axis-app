import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import 'cal_data.dart';

/// 캘린더 한 칸(40×40). 진행률만큼 파랗게 칠하고 오른쪽 아래에 선(계획대로·일부 조정·즉흥적으로)을 긋는다.
class CalDayCell extends StatelessWidget {
  const CalDayCell({super.key, required this.date, this.onTap, this.onLongPressStart, this.onLongPressEnd});

  final DateTime date;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  static const size = 40.0;

  @override
  Widget build(BuildContext context) {
    final record = CalData.recordFor(date);
    final today = CalData.isToday(date);
    final strong = record != null && record.progress >= 0.8;
    final textColor = record == null ? AppColors.gray04 : (strong ? Colors.white : AppColors.gray09);
    final label = record == null
        ? '${date.month}월 ${date.day}일${today ? ', 오늘' : ''}'
        : '${date.month}월 ${date.day}일${today ? ', 오늘' : ''}, 진행률 ${record.percent}%, ${record.mark.label}';

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPressStart: onLongPressStart == null ? null : (_) => onLongPressStart!(),
        onLongPressEnd: onLongPressEnd == null ? null : (_) => onLongPressEnd!(),
        onLongPressCancel: onLongPressEnd,
        child: SizedBox(
          width: size,
          height: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: record == null ? null : AppColors.primary.withValues(alpha: record.progress),
              ),
              child: Stack(
                children: [
                  if (record != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CalMarkPainter(
                          mark: record.mark,
                          color: record.progress >= 0.6 ? const Color(0xFFA0D5FF) : AppColors.primary,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 5,
                    top: 5,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1,
                        letterSpacing: -1,
                        fontWeight: record == null ? FontWeight.w500 : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (today)
                    Positioned(
                      left: 31,
                      top: 5,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 칸 오른쪽 아래 24×24 영역(중심 33,31)에 긋는 1.56px 선.
class CalMarkPainter extends CustomPainter {
  const CalMarkPainter({required this.mark, required this.color});

  final CalMark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.56
      ..strokeCap = StrokeCap.round;
    switch (mark) {
      case CalMark.plan:
        canvas.drawLine(const Offset(33, 19), const Offset(33, 43), paint);
      case CalMark.adjust:
        canvas.drawLine(const Offset(25, 40.5), const Offset(41, 21), paint);
      case CalMark.free:
        canvas.drawLine(const Offset(21, 31), const Offset(45, 31), paint);
    }
  }

  @override
  bool shouldRepaint(CalMarkPainter old) => old.mark != mark || old.color != color;
}

/// 날짜를 길게 눌렀을 때 뜨는 말풍선(#1F2027, 굴곡 10). 아래쪽 삼각형이 칸을 가리킨다.
class CalDayPreview extends StatelessWidget {
  const CalDayPreview({super.key, required this.date, this.pointerDx = 0});

  final DateTime date;

  /// 삼각형을 가운데에서 옮길 거리(말풍선이 화면 끝에 붙어 밀렸을 때).
  final double pointerDx;

  static const width = 157.0;
  static const height = 83.0; // 말풍선 75 + 삼각형 8

  @override
  Widget build(BuildContext context) {
    final record = CalData.recordFor(date);
    final String line2;
    final String line3;
    if (CalData.isFuture(date)) {
      line2 = '아직 다가오지 않은 날이에요';
      line3 = '눌러서 일정을 확인해요';
    } else if (record == null) {
      line2 = '진행률 0% · 기록 없음';
      line3 = '이날은 일정이 없었어요';
    } else {
      line2 = '진행률 ${record.percent}% · ${record.mark.label}';
      line3 = record.done == record.total ? '일정 ${record.total}개 모두 완료' : '일정 ${record.total}개 중 ${record.done}개 완료';
    }
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          Container(
            width: width,
            height: 75,
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 0),
            decoration: BoxDecoration(
              color: AppColors.gray07,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CalData.dayTitle(date),
                    style: const TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    line2,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFD1D6DB),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(line3, style: const TextStyle(fontSize: 12, height: 1.2, color: Color(0xFFB0B8C1))),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(pointerDx, 0),
            child: CustomPaint(size: const Size(14, 8), painter: _PointerPainter()),
          ),
        ],
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.gray07);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => false;
}

/// 말풍선을 칸 위에 놓을 위치. [cell]은 칸의 영역, [bounds]는 말풍선이 들어갈 영역 너비.
Offset calPreviewOrigin(Rect cell, double boundsWidth) {
  final wanted = cell.center.dx - CalDayPreview.width / 2;
  final left = wanted.clamp(8.0, boundsWidth - CalDayPreview.width - 8);
  return Offset(left, cell.top - 8 - CalDayPreview.height + 6);
}

/// 범례 아이콘(10×10).
class CalLegendIcon extends StatelessWidget {
  const CalLegendIcon(this.mark, {super.key});

  final CalMark mark;

  @override
  Widget build(BuildContext context) {
    final name = const ['plan', 'adjust', 'free'][mark.index];
    return SvgPicture.asset('assets/icons/cal_legend_$name.svg', width: 10, height: 10);
  }
}
