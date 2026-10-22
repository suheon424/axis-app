import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/main_chrome.dart';
import 'main/achievement_screen.dart';
import 'main/add_schedule_screen.dart';
import 'main/calendar_screen.dart';
import 'main/home_widgets.dart';

/// 07_01 홈(목록). 회색 상단 줄, 오늘의 실천 카드, 카테고리별 이번 달 기록 카드 6개.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.nickname});

  final String nickname;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// 카테고리 카드 하나의 내용.
class _Category {
  const _Category(this.name, this.color, this.days);

  final String name;
  final Color color;
  final int days;
}

const _categories = [
  _Category('Todo', CubeColors.blue, 18),
  _Category('Routine', CubeColors.red, 12),
  _Category('Study', CubeColors.yellow, 9),
  _Category('Travel', CubeColors.green, 4),
  _Category('Expenses', CubeColors.orange, 15),
  _Category('Workout', CubeColors.gray, 7),
];

/// 오늘의 실천에서 차례로 넘어가는 일정.
const _todaySchedule = [
  'AM 09:00 팀 회의',
  'AM 10:30 보고서 정리',
  'PM 12:30 팀 점심',
  'PM 03:00 영어 공부',
  'PM 06:30 헬스',
  'PM 09:00 가계부 정리',
];

class _HomeScreenState extends State<HomeScreen> {
  static const _headerColor = Color(0xFF858C94);

  int _done = 2;

  void _completeNext() {
    if (_done >= _todaySchedule.length) return;
    setState(() => _done++);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay.copyWith(statusBarColor: _headerColor),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          // 배경 사진 두 장(20%, 50% + 위쪽 회색 그라디언트). 위치는 피그마 기준(상단 줄 아래부터).
                          Positioned(
                            top: top - 48,
                            left: -1,
                            right: -1,
                            height: 849,
                            child: const Opacity(
                              opacity: 0.2,
                              child: Image(image: AssetImage(homeBgPhoto), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: top + 47,
                            left: 0,
                            right: -2,
                            height: 849,
                            child: const Stack(
                              fit: StackFit.expand,
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Image(image: AssetImage(homeBgPhoto), fit: BoxFit.cover),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0x33858C94), Color(0x00666666)],
                                      stops: [0, 0.37],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, top + 58 + 10, 20, 24),
                            child: Column(
                              children: [
                                _TodayCard(done: _done, onNext: _completeNext),
                                for (final c in _categories) ...[
                                  const SizedBox(height: 10),
                                  _CategoryCard(
                                    category: c,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const CalendarScreen(showCoachmarks: true),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 고정 상단 줄(회색).
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ColoredBox(
                      color: _headerColor,
                      child: Padding(
                        padding: EdgeInsets.only(top: top + 10),
                        child: HomeTopBar(
                          toggle: HomeSegmentToggle(
                            achievement: false,
                            onChanged: (v) {
                              if (v) homeSwitchTo(context, AchievementScreen(nickname: widget.nickname));
                            },
                          ),
                          onAdd: () =>
                              Navigator.of(context)
                                  .push(MaterialPageRoute<void>(builder: (_) => const AddScheduleScreen())),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const AxisTabBar(current: MainTab.home),
          ],
        ),
      ),
    );
  }
}

/// "오늘의 실천" 카드: 남은 개수, 6단계 바, 다음 일정 버튼(누르면 한 칸 실천).
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.done, required this.onNext});

  final int done;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final total = _todaySchedule.length;
    final left = total - done;
    final allDone = left == 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 15, height: 18 / 15, color: Colors.white),
                    children: [
                      const TextSpan(text: '오늘의 실천 '),
                      TextSpan(
                        text: allDone ? '모두 완료' : '$left개 남음',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    height: 16 / 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC9CEDA),
                  ),
                  children: [
                    TextSpan(
                      text: '$done',
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextSpan(text: ' / $total'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          HomeStepBar(total: total, done: done),
          const SizedBox(height: 18),
          HomeDarkButton(
            semanticLabel: allDone ? '오늘 일정을 모두 마쳤어요' : '다음 ${_todaySchedule[done]}',
            onTap: onNext,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: allDone
                  ? const Text(
                      '오늘 일정을 모두 마쳤어요',
                      key: ValueKey('done'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    )
                  : Row(
                      key: ValueKey(done),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '다음',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFC9CEDA)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _todaySchedule[done],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 카테고리 카드(흰 바탕 104): 이름, 이번 달 n/30일, 30일 칸, 오른쪽 화살표.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final _Category category;
  final VoidCallback onTap;

  static const _cellOff = Color(0x1A276DD6);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.name}, 이번 달 ${category.days}/30일',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: Container(
          height: 104,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 22,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                            children: [
                              const TextSpan(
                                text: '이번 달 ',
                                style: TextStyle(color: AppColors.gray05),
                              ),
                              TextSpan(text: '${category.days}/30일'),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                    SvgPicture.asset('assets/icons/home_ic_arrow_right.svg', width: 16, height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 19),
              // 30일 칸: 한 줄 23칸 × 2줄, 간격 4.
              LayoutBuilder(
                builder: (context, constraints) {
                  const cols = 23;
                  const gap = 4.0;
                  final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var i = 0; i < 30; i++)
                        Container(
                          width: w,
                          height: 9.3,
                          decoration: BoxDecoration(
                            color: i == 0 ? category.color : _cellOff,
                            borderRadius: BorderRadius.circular(1.7),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
