import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';

const _days = [22, 23, 24, 25, 26, 27, 28];
const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

/// 일정 목록(07_05)·지도 탭 위의 한 주 달력(2026년 11월 22~28일).
/// 요일 머리글 + Calendar/Day 칸. 고른 날은 회색 기둥(52×87, 굴곡 8)으로 감싸고 요일 글자가 파래진다.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.selected, required this.onSelect, required this.stateOf});

  final int selected;
  final ValueChanged<int> onSelect;

  /// 날짜별 실천 상태(일정 유무·완료 정도).
  final AxisDayState Function(int day) stateOf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: _DayColumn(
                weekday: _weekdays[i],
                day: _days[i],
                state: stateOf(_days[i]),
                selected: _days[i] == selected,
                onTap: () => onSelect(_days[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.weekday,
    required this.day,
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final String weekday;
  final int day;
  final AxisDayState state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '11월 $day일 $weekday요일',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 87,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 52,
                height: 87,
                decoration: BoxDecoration(
                  color: selected ? AppColors.gray02 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 11),
                  SizedBox(
                    height: 20,
                    child: Center(
                      child: Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: selected ? AppColors.brand : AppColors.weekday,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  AxisCalendarDay(day: day, state: state),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
