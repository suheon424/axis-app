import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'achievement_screen.dart';
import 'add_schedule_screen.dart';
import 'cal_coachmark.dart';
import 'cal_data.dart';
import 'cal_widgets.dart';
import 'schedule_list_screen.dart';

/// 07_04 캘린더. 카테고리(Todo)의 한 달 실천 기록을 날짜 칸 상태(진행 중·완료·시작 전·일정 없음·오늘)로 보여 준다.
/// [showCoachmarks]가 true면 처음 들어왔을 때 07_04 · 코치마크(v2)를 띄운다("다시 보지 않기"를 고르면 다시 띄우지 않는다).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.showCoachmarks = false, this.title = 'Todo', this.name = '수현'});

  final bool showCoachmarks;
  final String title;

  /// 인사 띠의 이름("수현 님").
  final String name;

  /// 코치마크에서 "다시 보지 않기"를 고르면 true(앱을 다시 켤 때까지).
  static bool coachmarkDismissed = false;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month = DateTime(CalData.today.year, CalData.today.month);
  int _direction = 0;
  late bool _coach = widget.showCoachmarks && !CalendarScreen.coachmarkDismissed;

  // 길게 누르기 미리보기
  final _stackKey = GlobalKey();
  DateTime? _previewDate;
  Rect? _previewCell;

  // 코치마크가 비출 대상
  final _addKey = GlobalKey();
  final _panelKey = GlobalKey();
  final _cardKey = GlobalKey();

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
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ScheduleListScreen()));
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

  void _closeCoach(bool dontShowAgain) {
    if (dontShowAgain) CalendarScreen.coachmarkDismissed = true;
    setState(() => _coach = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _coach
          ? darkScreenOverlay.copyWith(statusBarColor: const Color(0xFF1B1C20))
          : lightScreenOverlay.copyWith(statusBarColor: AppColors.gray01),
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
                backgroundColor: AppColors.gray01,
                bottomNavigationBar: const AxisTabBar(current: MainTab.home),
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      AxisBackTitleBar(
                        title: widget.title,
                        actions: [
                          AxisIconButton(
                            key: _addKey,
                            icon: KitIcon.navPlus,
                            tooltip: '일정 추가',
                            onPressed: () =>
                                Navigator.of(context)
                                    .push(MaterialPageRoute<void>(builder: (_) => const AddScheduleScreen())),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 15, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              KeyedSubtree(key: _panelKey, child: _buildPanel()),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: CalProgressCard(
                                  key: _cardKey,
                                  onTap: () =>
                                      Navigator.of(context)
                                          .push(MaterialPageRoute<void>(builder: (_) => const AchievementScreen())),
                                ),
                              ),
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
                  child: CalCoachmarkOverlay(
                    addKey: _addKey,
                    panelKey: _panelKey,
                    cardKey: _cardKey,
                    onClose: _closeCoach,
                  ),
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
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: AxisGreetingBanner(
                  key: ValueKey(_month),
                  name: '${widget.name} 님',
                  message: CalData.bannerMessage(_month),
                ),
              ),
            ),
            const SizedBox(height: 31),
            Padding(
              padding: const EdgeInsets.only(left: 23, right: 20),
              child: AxisMonthHeader(
                title: '${_month.year}년 ${_month.month}월',
                onPrev: () => _changeMonth(-1),
                onNext: _canGoNext ? () => _changeMonth(1) : null,
              ),
            ),
            const SizedBox(height: 7),
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
                    const AxisWeekdayHeader(),
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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    super.key,
    required this.month,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final DateTime month;
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
                  SizedBox(width: 47, height: 47, child: Center(child: _cell(r * 7 + c - lead + 1, days))),
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
      builder: (cellContext) => CalDayCell(
        date: date,
        onTap: () => onTap(date),
        onLongPressStart: () => onLongPressStart(date, cellContext),
        onLongPressEnd: onLongPressEnd,
      ),
    );
  }
}
