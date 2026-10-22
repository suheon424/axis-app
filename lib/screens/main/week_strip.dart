import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

const _days = [22, 23, 24, 25, 26, 27, 28];
const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

/// 일정 목록(07_05)·지도(07_09) 위의 한 주 달력(2026년 11월 22~28일).
/// 고른 날은 검은 기둥 + 하늘색 칸, 일정이 있는 23일엔 빨간 점.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            _DayColumn(
              weekday: _weekdays[i],
              day: _days[i],
              selected: _days[i] == selected,
              hasPlan: _days[i] == 23,
              onTap: () => onSelect(_days[i]),
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
    required this.selected,
    required this.hasPlan,
    required this.onTap,
  });

  final String weekday;
  final int day;
  final bool selected;
  final bool hasPlan;
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
          width: 46.57,
          height: 87,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 선택된 요일 기둥(52폭)은 칸(46.57)보다 조금 넓다.
              Positioned(
                left: (46.57 - 52) / 2,
                top: 0,
                width: 52,
                height: 87,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.gray09 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 7),
                  SizedBox(
                    height: 20,
                    child: Center(
                      child: Text(
                        weekday,
                        style: TextStyle(fontSize: 12, color: selected ? Colors.white : const Color(0xFFA3A7B2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFCCDDFB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          left: 5,
                          top: 5,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.2,
                              letterSpacing: -1,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? Colors.black : AppColors.gray04,
                            ),
                          ),
                        ),
                        if (hasPlan) ...[
                          Positioned(
                            left: 31,
                            top: 5,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(color: CubeColors.red, shape: BoxShape.circle),
                            ),
                          ),
                          if (selected)
                            Positioned(
                              left: 21,
                              top: 32,
                              child: Container(
                                width: 24,
                                height: 1.6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
