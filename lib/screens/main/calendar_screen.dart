import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/main_chrome.dart';
import 'achievement_screen.dart';
import 'add_schedule_screen.dart';
import 'cal_coachmark.dart';
import 'cal_data.dart';
import 'cal_widgets.dart';
import 'schedule_list_screen.dart';

const _gray01 = Color(0xFFF4F5FA);
const _gray02 = Color(0xFFEDEEF6);
const _legendText = Color(0xFF999999);

/// 07_04 캘린더. 카테고리(Todo)의 한 달 실천 기록을 칸 색(진행률)과 선(계획 변경 정도)으로 보여 준다.
/// [showCoachmarks]가 true면 처음 들어왔을 때 07_03 코치마크(1/4~4/4)를 띄운다.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.showCoachmarks = false, this.title = 'Todo', this.nickname = '황수현'});

  final bool showCoachmarks;
  final String title;
  final String nickname;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month = DateTime(CalData.today.year, CalData.today.month);
  int _direction = 0;
  late bool _coach = widget.showCoachmarks;

  // 길게 누르기 미리보기
  final _stackKey = GlobalKey();
  DateTime? _previewDate;
  Rect? _previewCell;

  // 코치마크가 비출 대상
  final _todayKey = GlobalKey();
  final _planKey = GlobalKey();
  final _previewKey = GlobalKey();
  final _legendKey = GlobalKey();

  static const _coachPlanDay = 14;
  static const _coachPreviewDay = 12;

  bool get _canGoNext =>
      DateTime(_month.year, _month.month + 1).isBefore(DateTime(CalData.today.year, CalData.today.month + 1));

  void _changeMonth(int delta) {
    if (delta > 0 && !_canGoNext) return;
    setState(() {
      _direction = delta;
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  void _openDay(DateTime date) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScheduleListScreen()));
  }

  void _showPreview(DateTime date, BuildContext cellContext) {
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final cell = cellContext.findRenderObject() as RenderBox?;
    if (stack == null || cell == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _previewDate = date;
      _previewCell = MatrixUtils.transformRect(cell.getTransformTo(stack), Offset.zero & cell.size);
    });
  }

  void _hidePreview() {
    if (_previewDate == null) return;
    setState(() => _previewDate = null);
  }

  List<CalCoachStep> get _coachSteps => [
    CalCoachStep(target: _todayKey, title: '빨간 점이 있는 날이 오늘이에요', body: '달력을 넘겨 보다가도\n오늘이 어디인지 바로 찾을 수 있어요.'),
    CalCoachStep(
      target: _planKey,
      title: '계획대로 지킨 날엔 세로선이 생겨요',
      body: '선이 기울수록 계획을 많이 바꾼 날이에요.\n칸 색이 진할수록 더 많이 실천한 날이고요.',
    ),
    CalCoachStep(
      target: _legendKey,
      isCell: false,
      cardAbove: true,
      title: '헷갈릴 땐 아래 범례를 보세요',
      body: '색이 진할수록 많이 실천했고,\n선이 기울수록 계획을 많이 바꿨어요.',
    ),
    CalCoachStep(
      target: _previewKey,
      title: '날짜를 길게 누르면 자세히 볼 수 있어요',
      body: '그날의 진행률과 완료한 일정 수를 보여드려요.',
      previewDate: DateTime(CalData.today.year, CalData.today.month, _coachPreviewDay),
      nextLabel: '시작하기',
    ),
  ];

  GlobalKey? _keyFor(DateTime d) {
    if (d.year != CalData.today.year || d.month != CalData.today.month) return null;
    if (d.day == CalData.today.day) return _todayKey;
    if (d.day == _coachPlanDay) return _planKey;
    if (d.day == _coachPreviewDay) return _previewKey;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 코치마크가 덮으면 표시줄도 어둡게(#F4F5FA 위 72% 검정).
      value: _coach
          ? darkScreenOverlay.copyWith(statusBarColor: const Color(0xFF444446))
          : lightScreenOverlay.copyWith(statusBarColor: _gray01),
      child: PopScope(
        canPop: !_coach,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _coach) setState(() => _coach = false);
        },
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            key: _stackKey,
            children: [
              Scaffold(
                backgroundColor: _gray01,
                bottomNavigationBar: const AxisTabBar(current: MainTab.home, light: true),
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 7),
                      _NavBar(
                        title: widget.title,
                        onAdd: () =>
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddScheduleScreen())),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 17, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPanel(),
                              _Legend(key: _legendKey),
                              const SizedBox(height: 16),
                              const _AchievementCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 길게 누르기 미리보기 말풍선
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween(begin: 0.92, end: 1.0).animate(anim),
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
                    ),
                    layoutBuilder: (current, previous) =>
                        Stack(fit: StackFit.expand, children: [...previous, ?current]),
                    child: _previewDate == null || _previewCell == null
                        ? const SizedBox.shrink(key: ValueKey('none'))
                        : LayoutBuilder(
                            key: ValueKey(_previewDate),
                            builder: (context, c) {
                              final origin = calPreviewOrigin(_previewCell!, c.maxWidth);
                              final dx = _previewCell!.center.dx - (origin.dx + CalDayPreview.width / 2);
                              return Stack(
                                children: [
                                  Positioned(
                                    left: origin.dx,
                                    top: origin.dy,
                                    child: CalDayPreview(date: _previewDate!, pointerDx: dx),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ),
              if (_coach)
                Positioned.fill(
                  child: CalCoachmarkOverlay(steps: _coachSteps, onClose: () => setState(() => _coach = false)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Banner(nickname: widget.nickname, message: CalData.bannerMessage(_month)),
            ),
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.only(left: 23),
              child: _MonthHeader(
                month: _month,
                canGoNext: _canGoNext,
                onPrev: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v > 250) _changeMonth(-1);
                if (v < -250) _changeMonth(1);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    const _WeekdayRow(),
                    const SizedBox(height: 10),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, anim) {
                          final incoming = child.key == ValueKey(_month);
                          final from = Offset(0.12 * _direction * (incoming ? 1 : -1), 0);
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween(begin: from, end: Offset.zero).animate(anim),
                              child: child,
                            ),
                          );
                        },
                        layoutBuilder: (current, previous) =>
                            Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
                        child: _MonthGrid(
                          key: ValueKey(_month),
                          month: _month,
                          keyFor: _keyFor,
                          onTap: _openDay,
                          onLongPressStart: _showPreview,
                          onLongPressEnd: _hidePreview,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          Positioned(
            left: 2,
            child: IconButton(
              tooltip: '뒤로',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: SvgPicture.asset('assets/icons/cal_ic_back.svg', width: 24, height: 24),
            ),
          ),
          Positioned(
            right: 5,
            child: IconButton(
              tooltip: '일정 추가',
              onPressed: onAdd,
              icon: SvgPicture.asset('assets/icons/cal_ic_plus.svg', width: 24, height: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.nickname, required this.message});

  final String nickname;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(colors: [AppColors.blue01, Color(0xFFEFF8FF)], stops: [0, 0.55857]),
      ),
      child: Row(
        children: [
          Text(
            '$nickname 님',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray09),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                message,
                key: ValueKey(message),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.canGoNext, required this.onPrev, required this.onNext});

  final DateTime month;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MonthArrow(asset: 'assets/icons/cal_ic_month_left.svg', label: '이전 달', enabled: true, onTap: onPrev),
        const SizedBox(width: 16),
        Text(
          '${month.year}년 ${month.month}월',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gray09),
        ),
        const SizedBox(width: 16),
        _MonthArrow(asset: 'assets/icons/cal_ic_month_right.svg', label: '다음 달', enabled: canGoNext, onTap: onNext),
      ],
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.asset, required this.label, required this.enabled, required this.onTap});

  final String asset;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: Pressable(
        onTap: enabled ? onTap : null,
        scale: 0.9,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: _gray02, borderRadius: BorderRadius.circular(6)),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1 : 0.5,
            child: SvgPicture.asset(
              asset,
              width: 26,
              height: 26,
              colorFilter: enabled ? null : const ColorFilter.mode(AppColors.gray05, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final w in CalData.weekdays)
          SizedBox(
            width: 46.57,
            height: 20,
            child: Center(
              child: Text(w, style: const TextStyle(fontSize: 12, color: Color(0xFFA3A7B2))),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    super.key,
    required this.month,
    required this.keyFor,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final DateTime month;
  final GlobalKey? Function(DateTime) keyFor;
  final ValueChanged<DateTime> onTap;
  final void Function(DateTime, BuildContext) onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final lead = DateTime(month.year, month.month, 1).weekday % 7; // 일요일 = 0
    final days = calDaysInMonth(month.year, month.month);
    final rows = ((lead + days) / 7).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var c = 0; c < 7; c++)
                  SizedBox(width: 46.57, height: 46.57, child: Center(child: _cell(r * 7 + c - lead + 1, days))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(int day, int days) {
    if (day < 1 || day > days) return const SizedBox(width: CalDayCell.size, height: CalDayCell.size);
    final date = DateTime(month.year, month.month, day);
    return Builder(
      key: keyFor(date),
      builder: (cellContext) => CalDayCell(
        date: date,
        onTap: () => onTap(date),
        onLongPressStart: () => onLongPressStart(date, cellContext),
        onLongPressEnd: onLongPressEnd,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({super.key});

  static const _style = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: -0.24, color: _legendText);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _gray02)),
      ),
      child: Row(
        children: [
          const Text('진행률 10%', style: _style),
          const SizedBox(width: 6),
          Container(
            width: 36,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(colors: [Color(0xFFE5EEFD), AppColors.primary]),
            ),
          ),
          const SizedBox(width: 6),
          const Text('100%', style: _style),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  for (final m in CalMark.values) ...[
                    if (m.index > 0) const SizedBox(width: 6),
                    Text(m.label, style: _style),
                    const SizedBox(width: 4),
                    CalLegendIcon(m),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard();

  @override
  Widget build(BuildContext context) {
    void open() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AchievementScreen()));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        button: true,
        label: '이번 달 달성률 확인하기',
        excludeSemantics: true,
        onTap: open,
        child: Pressable(
          onTap: open,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/cal_ic_cube.svg', width: 31.7, height: 36.6),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이번 달, 얼마나 실천했을까?', style: TextStyle(fontSize: 12, color: AppColors.gray09)),
                      SizedBox(height: 3),
                      Text(
                        '이번 달 달성률 확인하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset('assets/icons/cal_ic_chevron.svg', width: 24, height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
