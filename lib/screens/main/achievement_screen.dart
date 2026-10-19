import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../widgets/main_chrome.dart';
import '../home_screen.dart';
import 'calendar_screen.dart';
import 'home_spline_cube.dart';
import 'home_widgets.dart';

/// 07_02 달성률. 목록/달성률 토글의 달성률 쪽. 가운데 큐브는 Spline 3D 장면([SplineCube]).
class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key, this.nickname = ''});

  /// 목록(홈)으로 돌아갈 때 그대로 넘겨 준다.
  final String nickname;

  /// 배경 사진 꼭대기(50%) 색에 맞춘 상단 표시줄 색.
  static const _statusColor = Color(0xFF72777B);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay.copyWith(statusBarColor: _statusColor),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: top - 48,
                    left: 0,
                    right: -2,
                    height: 849,
                    child: const Opacity(
                      opacity: 0.5,
                      child: Image(image: AssetImage(homeBgPhoto), fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: top + 10),
                    child: Column(
                      children: [
                        HomeTopBar(
                          toggle: HomeSegmentToggle(
                            achievement: true,
                            background: const Color(0xFF454D58),
                            onChanged: (v) {
                              if (!v) homeSwitchTo(context, HomeScreen(nickname: nickname));
                            },
                          ),
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          '모든 계획의 달성률을 큐브로 보여줘요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const Text(
                          '면의 색은 카테고리, 맞춘 칸은 실천한 날이에요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFB0B8C1)),
                        ),
                        const Expanded(child: SplineCube()),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
                          child: _StatsCard(),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
                          child: _NextPieceCard(
                            onShowRemaining: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => const CalendarScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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

/// 맞춘 조각 · 연속 실천 두 칸.
class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 18),
      decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(8)),
      child: const IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(0x80636C78)))),
                child: _Stat(label: '맞춘 조각', value: '6/27'),
              ),
            ),
            Expanded(child: _Stat(label: '연속 실천', value: '1일')),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, height: 16.5 / 13, letterSpacing: -0.26, color: Colors.white),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(fontSize: 18, height: 16.5 / 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }
}

/// 다음 조각까지 남은 일정 카드(3단계 바 + 남은 일정 보기).
class _NextPieceCard extends StatelessWidget {
  const _NextPieceCard({required this.onShowRemaining});

  final VoidCallback onShowRemaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    children: [
                      TextSpan(text: '다음 조각까지 '),
                      TextSpan(text: '일정 2개', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFC9CEDA)),
                  children: [
                    TextSpan(text: '1', style: TextStyle(color: Colors.white)),
                    TextSpan(text: ' / 3'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const HomeStepBar(total: 3, done: 1, gap: 6, todoColor: Color(0x0FFFFFFF)),
          const SizedBox(height: 18),
          HomeDarkButton(
            semanticLabel: '남은 일정 보기',
            color: const Color(0x1FFFFFFF),
            onTap: onShowRemaining,
            child: const Text(
              '남은 일정 보기',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
