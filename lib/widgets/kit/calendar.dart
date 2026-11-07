import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';

/// Calendar/Weekdays(130:9922): 일~토 요일 머리글(12 Regular #A3A7B2). [highlight] 칸은 파랑.
class AxisWeekdayHeader extends StatelessWidget {
  const AxisWeekdayHeader({super.key, this.highlight, this.labels = const ['일', '월', '화', '수', '목', '금', '토']});

  /// 강조할 요일(0=일). 보통 오늘 요일.
  final int? highlight;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Text(
              labels[i],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.4, color: i == highlight ? AppColors.brand : AppColors.weekday),
            ),
          ),
      ],
    );
  }
}

/// Calendar/Month Header(130:10071): ‹ 2026년 11월 › (22 Bold). 화살표 칸은 26px 회색 상자.
class AxisMonthHeader extends StatelessWidget {
  const AxisMonthHeader({super.key, required this.title, this.onPrev, this.onNext});

  /// 예: "2026년 11월"
  final String title;

  /// null이면 그 화살표가 흐려지고 눌리지 않는다.
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MonthArrow(next: false, onTap: onPrev),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            height: 1.3,
            letterSpacing: -0.22,
            fontWeight: FontWeight.w700,
            color: AppColors.gray09,
          ),
        ),
        const SizedBox(width: 16),
        _MonthArrow(next: true, onTap: onNext),
      ],
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.next, required this.onTap});

  final bool next;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = AxisIcon(KitIcon.navBack, size: 18, color: onTap == null ? AppColors.gray04 : AppColors.gray06);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: next ? '다음 달' : '이전 달',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onTap == null ? AppColors.gray01 : AppColors.gray02,
              borderRadius: BorderRadius.circular(6),
            ),
            child: next ? Transform.flip(flipX: true, child: icon) : icon,
          ),
        ),
      ),
    );
  }
}

/// Calendar/Day(130:10110)의 상태.
enum AxisDayState {
  /// 일부 실천: 파란 테두리 + 왼쪽 위 파란 사선 조각, 흰 날짜.
  inProgress,

  /// 모두 실천: 파랑으로 채움, 흰 날짜.
  done,

  /// 아직 실천 전(일정 있음): 파란 테두리, 파란 날짜.
  scheduled,

  /// 오늘(일정 없음): 흰 바탕, 파란 날짜.
  today,

  /// 일정 없음: 흰 바탕, 회색(#BDC3D0) 날짜.
  empty,
}

/// Calendar/Day(130:10110): 굴곡 6의 날짜 칸(기본 40px). 날짜는 왼쪽 위 14 SemiBold.
class AxisCalendarDay extends StatelessWidget {
  const AxisCalendarDay({super.key, required this.day, required this.state, this.size = 40, this.onTap});

  final int day;
  final AxisDayState state;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final k = size / 40;
    final border = state == AxisDayState.inProgress || state == AxisDayState.scheduled;
    final textColor = switch (state) {
      AxisDayState.inProgress || AxisDayState.done => Colors.white,
      AxisDayState.scheduled || AxisDayState.today => AppColors.brand,
      AxisDayState.empty => AppColors.gray04,
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: state == AxisDayState.done ? AppColors.brand : Colors.white,
          borderRadius: BorderRadius.circular(6 * k),
          border: border ? Border.all(color: AppColors.brand, width: math.max(0.7, k)) : null,
        ),
        child: Stack(
          children: [
            if (state == AxisDayState.inProgress) Positioned.fill(child: CustomPaint(painter: _SlashPainter())),
            Positioned(
              left: 5 * k,
              top: 2 * k,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: math.max(12, 14 * k),
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 37.5 / 40, 0)
      ..lineTo(w * 10.5 / 40, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.brand);
  }

  @override
  bool shouldRepaint(_SlashPainter old) => false;
}

/// Coachmark/Legend Item(130:10123): 작은 날짜 칸(28) + 상태 이름(14 SemiBold) + 설명(14 Regular gray06).
class AxisDayLegendItem extends StatelessWidget {
  const AxisDayLegendItem({
    super.key,
    required this.state,
    required this.label,
    required this.description,
    this.day = 8,
  });

  final AxisDayState state;
  final String label;
  final String description;
  final int day;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AxisCalendarDay(day: day, state: state, size: 28),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.gray07),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(description, style: AxisText.body.copyWith(color: AppColors.gray06)),
        ),
      ],
    );
  }
}

/// Header/Schedule Day(130:10089): "11월 23일 월요일"(18 Bold) + "일정 6개" + J모드 칩 + 필터 드롭다운.
class AxisScheduleDayHeader extends StatelessWidget {
  const AxisScheduleDayHeader({
    super.key,
    required this.title,
    this.countLabel,
    this.jMode,
    this.onJModeTap,
    this.filterLabel,
    this.onFilterTap,
  });

  final String title;

  /// 예: "일정 6개"
  final String? countLabel;

  /// null이면 J모드 칩을 숨긴다. true면 파란 칩.
  final bool? jMode;
  final VoidCallback? onJModeTap;

  /// null이면 드롭다운을 숨긴다. 예: "전체"
  final String? filterLabel;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(title, style: AxisText.title18),
              if (countLabel != null) Text(countLabel!, style: AxisText.body.copyWith(color: AppColors.gray06)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (jMode != null)
          GestureDetector(
            onTap: onJModeTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 26),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: jMode! ? AppColors.brand : AppColors.segmentBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'J모드',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: jMode! ? Colors.white : AppColors.gray06,
                ),
              ),
            ),
          ),
        if (filterLabel != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 26),
              padding: const EdgeInsets.fromLTRB(8, 2, 6, 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.gray02),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filterLabel!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray07,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const AxisIcon(KitIcon.chevronDownSmall, size: 14),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
