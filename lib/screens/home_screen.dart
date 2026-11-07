import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/kit/kit.dart';
import 'main/achievement_screen.dart';
import 'main/add_schedule_screen.dart';
import 'main/home_widgets.dart';
import 'main/schedule_list_screen.dart';

/// 홈_목록이 보여 주는 상태.
enum HomeLoadState {
  /// 07_01 홈_목록 · 로딩: 카드 자리에 깜빡이는 막대.
  loading,

  /// 07_01 홈_목록
  ready,

  /// 07_01 홈_목록 · 네트워크 오류
  error,
}

/// 07_01 홈_목록(홈 탭 첫 화면). 회색 상단 줄, 오늘의 실천 카드, "이번 달 실천" 카테고리 목록.
///
/// 처음 열면 [initialState](기본 로딩)를 잠깐 보여 준 뒤 목록을 띄운다.
/// [askNotificationPermission]이 true면 목록이 뜬 뒤 07_01 · 알림 권한 요청 대화상자를 띄운다.
/// 데모: axis 로고를 길게 누르면 로딩·네트워크 오류·알림 권한 요청을 골라 볼 수 있다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.nickname = '',
    this.initialState = HomeLoadState.loading,
    this.askNotificationPermission = false,
  });

  final String nickname;
  final HomeLoadState initialState;
  final bool askNotificationPermission;

  /// 로딩 화면을 보여 주는 시간.
  static const loadingDuration = Duration(milliseconds: 700);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// 카테고리 한 줄의 내용.
class _Category {
  const _Category(this.name, this.color, this.days);

  final String name;
  final Color color;
  final int days;

  int get percent => (days / 30 * 100).round();
}

const _categories = [
  _Category('Todo', AppColors.brand, 18),
  _Category('Routine', CubeColors.red, 12),
  _Category('Study', CubeColors.yellow, 9),
  _Category('Travel', CubeColors.green, 4),
  _Category('Expenses', CubeColors.orange, 15),
  _Category('Workout', CubeColors.gray, 7),
];

/// 오늘의 실천에서 차례로 넘어가는 일정.
const _todaySchedule = [
  '09:00 AM 팀 회의',
  '10:30 AM 보고서 정리',
  '12:30 PM 팀 점심',
  '03:00 PM 영어 공부',
  '06:30 PM 헬스',
  '09:00 PM 가계부 정리',
];

class _HomeScreenState extends State<HomeScreen> {
  static const _headerColor = Color(0xFF858C94);

  late HomeLoadState _state = widget.initialState;
  Timer? _loadTimer;
  int _done = 2;

  @override
  void initState() {
    super.initState();
    if (_state == HomeLoadState.loading) {
      _startLoading(first: true);
    } else if (_state == HomeLoadState.ready && widget.askNotificationPermission) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askNotification());
    }
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  void _startLoading({bool first = false}) {
    _loadTimer?.cancel();
    if (!first) setState(() => _state = HomeLoadState.loading);
    _loadTimer = Timer(HomeScreen.loadingDuration, () {
      if (!mounted) return;
      setState(() => _state = HomeLoadState.ready);
      if (first && widget.askNotificationPermission) _askNotification();
    });
  }

  Future<void> _askNotification() async {
    if (!mounted) return;
    final allow = await showAxisConfirm(
      context,
      title: '알림을 켜 둘까요?',
      message: '출발 시간과 일정 변경을 바로 알려 드려요.',
      confirmLabel: '허용하기',
      otherLabel: '나중에',
      destructive: false,
    );
    if (!mounted || allow != true) return;
    showAxisToast(context, '알림을 켰어요', bottom: 82);
  }

  void _completeNext() {
    if (_done >= _todaySchedule.length) return;
    setState(() => _done++);
  }

  /// 데모용 상태 고르기(로고 길게 누르기).
  Future<void> _pickDemoState() async {
    final picked = await showAxisSheet<int>(
      context,
      title: '화면 상태 보기',
      builder: (ctx) => Column(
        children: [
          for (final (i, label) in const ['로딩', '네트워크 오류', '알림 권한 요청'].indexed)
            AxisMenuRow(label: label, onTap: () => Navigator.of(ctx).pop(i)),
        ],
      ),
    );
    if (!mounted || picked == null) return;
    switch (picked) {
      case 0:
        _startLoading();
      case 1:
        _loadTimer?.cancel();
        setState(() => _state = HomeLoadState.error);
      case 2:
        _loadTimer?.cancel();
        setState(() => _state = HomeLoadState.ready);
        await _askNotification();
    }
  }

  void _openCategory() =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ScheduleListScreen()));

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay.copyWith(statusBarColor: _headerColor),
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: const AxisTabBar(current: MainTab.home),
        body: Stack(
          children: [
            Positioned.fill(child: HomeBackground(top: top)),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, top + 58 + 10, 20, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(key: ValueKey(_state), child: _content()),
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
                    achievement: false,
                    onToggle: (_) => homeSwitchTo(context, AchievementScreen(nickname: widget.nickname)),
                    onAdd: () =>
                        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddScheduleScreen())),
                    onLogoLongPress: _pickDemoState,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return switch (_state) {
      HomeLoadState.error => HomeErrorCard(onRetry: _startLoading),
      HomeLoadState.loading => const Column(
        children: [_TodaySkeleton(), SizedBox(height: 26), _SectionTitle(), SizedBox(height: 10), _ListSkeleton()],
      ),
      HomeLoadState.ready => Column(
        children: [
          _TodayCard(done: _done, onNext: _completeNext),
          const SizedBox(height: 26),
          const _SectionTitle(),
          const SizedBox(height: 10),
          HomeDarkCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (final (i, c) in _categories.indexed)
                  HomeCategoryRow(
                    color: c.color,
                    title: c.name,
                    subtitle: '30일 중 ${c.days}일 실천',
                    percent: c.percent,
                    divider: i < _categories.length - 1,
                    onTap: _openCategory,
                  ),
              ],
            ),
          ),
        ],
      ),
    };
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text('이번 달 실천', style: AxisText.sectionTitle.copyWith(color: Colors.white)),
    );
  }
}

/// "오늘의 실천" 카드: 남은 개수, % 완료, 6단계 바, "다음 …"(누르면 한 칸 실천).
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.done, required this.onNext});

  final int done;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final total = _todaySchedule.length;
    final left = total - done;
    final allDone = left == 0;
    final percent = (done / total * 100).round();
    return HomeDarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      letterSpacing: -0.32,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: '오늘의 실천 '),
                      TextSpan(
                        text: allDone ? '모두 완료' : '$left개 남음',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 12, height: 1.36, color: Color(0xB3FFFFFF)),
                  children: [
                    TextSpan(
                      text: '$percent%',
                      style: const TextStyle(color: Color(0xFF7DB8FF)),
                    ),
                    const TextSpan(text: ' 완료'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AxisStepBar(total: total, done: done),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: allDone ? '오늘 일정을 모두 마쳤어요' : '다음 ${_todaySchedule[done]}, 눌러서 실천',
            excludeSemantics: true,
            onTap: onNext,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onNext,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 24, minWidth: double.infinity),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  layoutBuilder: (current, previous) =>
                      Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
                  child: allDone
                      ? const Text(
                          '오늘 일정을 모두 마쳤어요',
                          key: ValueKey('done'),
                          style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: Colors.white),
                        )
                      : Row(
                          key: ValueKey(done),
                          children: [
                            const Text(
                              '다음',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFC9CEDA),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _todaySchedule[done],
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 로딩 중 오늘의 실천 카드 자리.
class _TodaySkeleton extends StatelessWidget {
  const _TodaySkeleton();

  @override
  Widget build(BuildContext context) {
    return const HomeDarkCard(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSkeletonBar(width: 140),
          SizedBox(height: 14),
          HomeSkeletonBar(width: double.infinity, height: 4),
          SizedBox(height: 18),
          HomeSkeletonBar(width: 200),
        ],
      ),
    );
  }
}

/// 로딩 중 카테고리 목록 자리(6줄).
class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return HomeDarkCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          for (var i = 0; i < 6; i++)
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const HomeSkeletonBar(width: 12, height: 12, radius: 2),
                  const SizedBox(width: 12),
                  HomeSkeletonBar(width: i.isEven ? 96 : 72),
                  const Spacer(),
                  const HomeSkeletonBar(width: 92),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
