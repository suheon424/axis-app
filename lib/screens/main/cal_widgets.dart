import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';
import 'cal_data.dart';

/// 캘린더 한 칸(40×40, 피그마 Calendar/Day). 누르면 그날 일정, 길게 누르면 미리보기.
class CalDayCell extends StatelessWidget {
  const CalDayCell({super.key, required this.date, this.onTap, this.onLongPressStart, this.onLongPressEnd});

  final DateTime date;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  static const size = 40.0;

  @override
  Widget build(BuildContext context) {
    final state = CalData.stateFor(date);
    final today = CalData.isToday(date);
    final label = '${date.month}월 ${date.day}일${today ? ', 오늘' : ''}, ${state.label}';
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
        child: AxisCalendarDay(day: date.day, state: state),
      ),
    );
  }
}

/// 날짜를 길게 눌렀을 때 뜨는 말풍선(#1F2027, 굴곡 10). 아래쪽 삼각형이 칸을 가리킨다.
class CalDayPreview extends StatelessWidget {
  const CalDayPreview({super.key, required this.date, this.pointerDx = 0});

  final DateTime date;

  /// 삼각형을 가운데에서 옮길 거리(말풍선이 화면 끝에 붙어 밀렸을 때).
  final double pointerDx;

  static const width = 168.0;
  static const height = 83.0; // 말풍선 75 + 삼각형 8

  @override
  Widget build(BuildContext context) {
    final record = CalData.recordFor(date);
    final state = CalData.stateFor(date);
    final line2 = state.label;
    final String line3;
    if (record == null) {
      line3 = '등록된 일정이 없어요';
    } else if (record.done == record.total) {
      line3 = '일정 ${record.total}개 모두 완료';
    } else {
      line3 = '일정 ${record.total}개 중 ${record.done}개 완료';
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

/// 말풍선을 칸 위에 놓을 위치. [cell]은 칸의 영역, [boundsWidth]는 말풍선이 들어갈 영역 너비.
Offset calPreviewOrigin(Rect cell, double boundsWidth) {
  final wanted = cell.center.dx - CalDayPreview.width / 2;
  final left = wanted.clamp(8.0, boundsWidth - CalDayPreview.width - 8);
  return Offset(left, cell.top - 8 - CalDayPreview.height + 6);
}

/// "이번 달, 얼마나 실천했을까요? / 계획 진척도 확인하기" 카드(흰 바탕, 굴곡 8).
class CalProgressCard extends StatelessWidget {
  const CalProgressCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: '계획 진척도 확인하기',
      onTap: onTap,
      builder: (context, pressed) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: pressed ? AppColors.gray01 : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset('assets/icons/cal_ic_cube.svg', width: 32, height: 37),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이번 달, 얼마나 실천했을까요?', style: AxisText.caption.copyWith(color: AppColors.gray09)),
                  const SizedBox(height: 1),
                  const Text(
                    '계획 진척도 확인하기',
                    style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.brand),
                  ),
                ],
              ),
            ),
            const AxisChevronRight(size: 24),
          ],
        ),
      ),
    );
  }
}
