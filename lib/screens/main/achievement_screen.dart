import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import '../home_screen.dart';
import 'calendar_screen.dart';
import 'home_spline_cube.dart';
import 'home_widgets.dart';

/// 07_01 홈_달성률. 목록/달성률 토글의 달성률 쪽. 가운데 큐브는 Spline 3D 장면([SplineCube]).
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
        bottomNavigationBar: const AxisTabBar(current: MainTab.home),
        body: Stack(
          children: [
            Positioned.fill(child: HomeBackground(top: top - 95)),
            Padding(
              padding: EdgeInsets.only(top: top + 10),
              child: Column(
                children: [
                  HomeTopBar(
                    achievement: true,
                    onToggle: (_) =>
                        homeSwitchTo(context, HomeScreen(nickname: nickname, initialState: HomeLoadState.ready)),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    '모든 계획의 달성률을\n큐브로 확인하세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, height: 1.4, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '면의 색은 카테고리, 맞춘 칸은 실천한 날이에요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFFB0B8C1)),
                  ),
                  // 화면이 작으면 큐브 칸이 줄어든다.
                  const Flexible(
                    child: SizedBox(
                      height: 260,
                      child: SplineCube(
                        imageOffset: Offset(0, -6),
                        fingerOffset: Offset(0, 18),
                        sceneOffset: Offset(5, -12),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
                    child: _StatsCard(),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
                    child: _NextPieceCard(
                      onShowRemaining: () => Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (_) => const CalendarScreen(showCoachmarks: true))),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
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
    return const HomeDarkCard(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Stat(label: '맞춘 조각', value: '6/27'),
            ),
            VerticalDivider(width: 1, thickness: 1, color: homeTrackColor),
            Expanded(
              child: _Stat(label: '연속 실천', value: '1일'),
            ),
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
        Text(label, style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xCCFFFFFF))),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w700, color: Colors.white),
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
    return HomeDarkCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  '다음 조각까지 일정 2개',
                  style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: Color(0xFFC9CEDA)),
                  children: [
                    TextSpan(
                      text: '1',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(text: ' / 3'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const AxisStepBar(total: 3, done: 1, doneColor: AppColors.brand),
          const SizedBox(height: 16),
          PressBuilder(
            semanticLabel: '남은 일정 보기',
            onTap: onShowRemaining,
            builder: (context, pressed) => Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: pressed ? const Color(0x33FFFFFF) : homeTrackColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '남은 일정 보기',
                style: TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
