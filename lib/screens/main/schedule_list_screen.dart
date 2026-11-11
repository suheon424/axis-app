import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import '../badge/badge_celebration.dart';
import 'add_schedule_screen.dart';
import 'list_ai.dart';
import 'list_data.dart';
import 'list_parts.dart';
import 'list_sheets.dart';
import 'map_screen.dart';
import 'week_strip.dart';

/// 07_05 일정 목록(Todo). 머리글의 "J모드" 칩으로 07_06 J모드(시간 + AI 꼬리표)와 오간다.
/// - 체크박스로 완료 표시, 6개를 모두 체크하면 배지 획득 축하(11_뱃지획득).
/// - 일정이 없는 날은 빈 상태(07_05 빈 상태) + "일정 추가하기".
/// - J모드에서 꼬리표를 누르면 제안이 펼쳐진다(07_07).
/// - 일정을 왼쪽으로 밀면 "이동 · 삭제"(07_07 이동/삭제).
/// - 일정을 누르면 상세 시트(07_08) → 더보기(07_08-1) → 삭제 확인(07_08-2).
/// - "틀어진 일정 맞추기" → AI 분석 중(07_05-1) → AI 일정 제안(07_05-2) → 맞추기 완료 토스트(07_06 완료).
/// - 목록 / 지도 탭: 지도는 같은 화면 안에서 [MapTab]으로 바꿔 보여 준다.
class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key, this.initialJMode = false, this.empty = false, this.initialDate});

  /// 07_04 캘린더에서 고른 날짜. 이번 주 띠(11월 22~28일) 안이면 그 날을 골라 둔 채로 연다.
  final DateTime? initialDate;

  /// J모드를 켠 채로 연다(07_06 확인용).
  final bool initialJMode;

  /// 23일 일정을 비운 채로 연다(07_05 빈 상태 확인용).
  final bool empty;

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

enum _Filter { all, todo, done }

extension on _Filter {
  String get label => const ['전체', '미완료', '완료'][index];
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  static const _scheduleDay = 23;

  /// 23일 말고는 피그마 07_05의 고정 상태.
  static const _otherDays = {
    22: AxisDayState.empty,
    24: AxisDayState.today,
    25: AxisDayState.empty,
    26: AxisDayState.scheduled,
    27: AxisDayState.inProgress,
    28: AxisDayState.done,
  };

  late final List<ListSchedule> _items = widget.empty ? [] : listSampleSchedules();
  late bool _jMode = widget.initialJMode;
  _Filter _filter = _Filter.all;
  late int _selectedDay = _initialDay();

  int _initialDay() {
    final d = widget.initialDate;
    if (d != null && d.year == 2026 && d.month == 11 && d.day >= 22 && d.day <= 28) return d.day;
    return _scheduleDay;
  }

  int? _openSwipeId;
  bool _mapTab = false;
  final _mapKey = GlobalKey<MapTabState>();
  final _filterKey = GlobalKey();
  final Set<int> _expanded = {};
  bool _badgeShown = false;

  List<ListSchedule> get _dayItems => _selectedDay == _scheduleDay ? _items : const [];

  List<ListSchedule> get _visible => switch (_filter) {
    _Filter.all => _dayItems,
    _Filter.todo => _dayItems.where((e) => !e.done).toList(),
    _Filter.done => _dayItems.where((e) => e.done).toList(),
  };

  AxisDayState _dayState(int day) {
    if (day != _scheduleDay) return _otherDays[day] ?? AxisDayState.empty;
    final done = _items.where((e) => e.done).length;
    if (_items.isEmpty) return AxisDayState.today;
    if (done == 0) return AxisDayState.scheduled;
    if (done == _items.length) return AxisDayState.done;
    return AxisDayState.inProgress;
  }

  void _toast(String message) => showAxisToast(context, message, bottom: 82);

  void _closeSwipe() {
    if (_openSwipeId != null) setState(() => _openSwipeId = null);
  }

  void _toggle(ListSchedule item) {
    setState(() {
      item.done = !item.done;
      _openSwipeId = null;
    });
    final doneCount = _items.where((e) => e.done).length;
    if (!_badgeShown && item.done && doneCount >= 6) {
      _badgeShown = true;
      Future.delayed(const Duration(milliseconds: 250), () {
        // 11_뱃지획득(130:13419) 그대로: 각성의 순간 배지 GIF와 문구.
        if (mounted) showBadgeCelebration(context, medal: AxisMedal.awakening);
      });
    }
  }

  void _openAdd([ListSchedule? item]) {
    _closeSwipe();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddScheduleScreen(initialTitle: item?.title, initialDate: DateTime(2026, 11, _selectedDay)),
      ),
    );
  }

  Future<void> _openDetail(ListSchedule item) async {
    _closeSwipe();
    final action = await showListDetailSheet(context, item);
    if (!mounted || action == null) return;
    switch (action) {
      case ListSheetAction.edit:
        _openAdd(item);
      case ListSheetAction.changeDate:
        await _changeDate(item);
      case ListSheetAction.delete:
        await _confirmDelete(item);
    }
  }

  Future<void> _changeDate(ListSchedule item) async {
    _closeSwipe();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 11, _scheduleDay),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      helpText: '${item.title} 날짜 변경',
      cancelText: '취소',
      confirmText: '옮기기',
    );
    if (!mounted || picked == null) return;
    if (picked == DateTime(2026, 11, _scheduleDay)) return;
    setState(() => _items.remove(item));
    _toast('‘${item.title}’을(를) ${picked.month}월 ${picked.day}일로 옮겼어요');
  }

  Future<void> _confirmDelete(ListSchedule item) async {
    _closeSwipe();
    final scope = await showListDeleteDialog(context);
    if (!mounted || scope == null) return;
    setState(() {
      _items.remove(item);
      _expanded.remove(item.id);
    });
    _toast(scope == ListDeleteScope.onlyThis ? '‘${item.title}’ 일정을 삭제했어요' : '‘${item.title}’ 이후 일정을 모두 삭제했어요');
  }

  Future<void> _runAi() async {
    _closeSwipe();
    final finished = await showListAiAnalyzing(context);
    if (!mounted || finished != true) return;
    final apply = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const ListAiSuggestionScreen()));
    if (!mounted || apply != true) return;
    setState(() {
      _jMode = true;
      ListSchedule? byId(int id) => _items.where((e) => e.id == id).firstOrNull;
      final lunch = byId(3);
      final bill = byId(6);
      lunch
        ?..time = '01:00 PM'
        ..endTime = '02:00 PM';
      if (bill != null) {
        bill
          ..time = '02:35 PM'
          ..endTime = '02:45 PM';
        // 관리비 납부를 팀 점심 바로 뒤로 옮긴다.
        _items.remove(bill);
        final at = lunch == null ? _items.length : _items.indexOf(lunch) + 1;
        _items.insert(at, bill);
      }
    });
    final left = _items.where((e) => !e.done).length;
    _toast('남은 일정 $left개를 다시 맞췄어요');
  }

  Future<void> _pickFilter() async {
    final box = _filterKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final rect = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    final picked = await showMenu<_Filter>(
      context: context,
      position: RelativeRect.fromRect(rect.shift(Offset(0, rect.height + 4)), Offset.zero & overlay.size),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.gray02),
      ),
      items: [
        for (final f in _Filter.values)
          PopupMenuItem(
            value: f,
            height: 44,
            child: Text(
              f.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: f == _filter ? FontWeight.w600 : FontWeight.w500,
                color: f == _filter ? AppColors.brand : AppColors.gray07,
              ),
            ),
          ),
      ],
    );
    if (picked != null && mounted) setState(() => _filter = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: AppColors.gray01),
      child: Scaffold(
        backgroundColor: AppColors.gray01,
        bottomNavigationBar: const AxisTabBar(current: MainTab.home),
        body: SafeArea(
          bottom: false,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _openSwipeId == null ? null : _closeSwipe,
            child: Column(
              children: [
                // 07_04~07_09: 상단 제목 줄은 스크롤해도 따라 올라가지 않게 고정(10-x 이벤트 상세와 같은 방식).
                AxisBackTitleBar(
                  title: 'Todo',
                  backgroundColor: AppColors.gray01,
                  actions: [AxisIconButton(icon: KitIcon.navPlus, tooltip: '일정 추가', onPressed: _openAdd)],
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 14),
                            _calendarCard(),
                            const SizedBox(height: 10),
                            AxisSegmentedTabs(
                              labels: const ['목록', '지도'],
                              selected: _mapTab ? 1 : 0,
                              onChanged: (i) => setState(() {
                                _mapTab = i == 1;
                                _openSwipeId = null;
                              }),
                            ),
                            if (_mapTab)
                              ColoredBox(
                                color: Colors.white,
                                child: MapTab(key: _mapKey, day: _selectedDay),
                              )
                            else ...[
                              _listSection(),
                              // 아래 떠 있는 버튼에 마지막 줄이 가리지 않게 비워 둔다.
                              SizedBox(height: _dayItems.isNotEmpty ? 40 + 37 + 24 : 40),
                            ],
                          ],
                        ),
                      ),
                      // 목록·지도 모두 AI 버튼은 스크롤과 상관없이 하단바 위 24에 고정.
                      if (!_mapTab && _dayItems.isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 24,
                          child: Center(child: ListFixButton(onTap: _runAi)),
                        ),
                      if (_mapTab)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 24,
                          child: Center(child: MapOptimizeButton(onTap: () => _mapKey.currentState?.openOptimize())),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── 위 카드: 월 머리글 · 한 주 달력
  Widget _calendarCard() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: AxisMonthHeader(title: '2026년 11월', onPrev: () => _toast('지난 일정은 홈의 달력에서 볼 수 있어요')),
          ),
          // 피그마: 월 머리글 아래 18 → 회색 기둥(52×87) 위 끝.
          const SizedBox(height: 18),
          WeekStrip(
            selected: _selectedDay,
            stateOf: _dayState,
            onSelect: (d) => setState(() {
              _selectedDay = d;
              _openSwipeId = null;
            }),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── 아래 카드: 날짜 머리글 · 일정
  Widget _listSection() {
    final visible = _visible;
    final weekday = _weekdays[(_selectedDay - 22) % 7];
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray05)),
            ),
            child: KeyedSubtree(
              key: _filterKey,
              child: AxisScheduleDayHeader(
                title: '11월 $_selectedDay일 $weekday요일',
                countLabel: '일정 ${_dayItems.length}개',
                jMode: _jMode,
                onJModeTap: () => setState(() {
                  _jMode = !_jMode;
                  _openSwipeId = null;
                }),
                filterLabel: _filter.label,
                onFilterTap: _pickFilter,
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _dayItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 50),
                    child: AxisEmptyState(
                      icon: KitIcon.navPlus,
                      title: '이날은 아직 일정이 없어요',
                      description: '일정을 추가하면 출발 시간과 동선을\n알아서 맞춰 드려요.',
                      actionLabel: '일정 추가하기',
                      onAction: _openAdd,
                    ),
                  )
                : visible.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text('${_filter.label} 일정이 없어요', style: AxisText.body),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < visible.length; i++)
                        _row(visible[i], _items.indexOf(visible[i]) + 1, isLast: i == visible.length - 1),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(ListSchedule item, int number, {required bool isLast}) {
    return _SwipeRow(
      key: ValueKey('row-${item.id}'),
      open: _openSwipeId == item.id,
      onOpenChanged: (open) => setState(() => _openSwipeId = open ? item.id : null),
      onMove: () => _changeDate(item),
      onDelete: () => _confirmDelete(item),
      showDivider: !isLast,
      child: _rowContent(item, number),
    );
  }

  Widget _rowContent(ListSchedule item, int number) {
    final tag = _jMode ? item.tag : null;
    final expanded = tag != null && _expanded.contains(item.id);
    void toggleTag() => setState(() => expanded ? _expanded.remove(item.id) : _expanded.add(item.id));
    return Semantics(
      button: true,
      label: '${item.title} 상세 보기',
      onTap: () => _openDetail(item),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openDetail(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 17,
                    child: Text(
                      '$number',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: -0.32,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  if (_jMode) ...[
                    SizedBox(width: 56, child: Text(item.time, maxLines: 1, softWrap: false, style: AxisText.caption)),
                    const SizedBox(width: 7),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: AxisText.rowTitle.copyWith(color: Colors.black, letterSpacing: -0.32),
                          ),
                        ),
                        if (tag != null) ...[
                          const SizedBox(width: 9),
                          Semantics(
                            button: true,
                            expanded: expanded,
                            label: '${tag.label} 제안 ${expanded ? '접기' : '펼치기'}',
                            excludeSemantics: true,
                            onTap: toggleTag,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: toggleTag,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: AxisTag(tag.label, tone: tag.tone),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(12, 0),
                    child: ListCheckbox(checked: item.done, label: item.title, onTap: () => _toggle(item)),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: expanded ? _suggestionPanel(item, tag) : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 07_07 펼친 제안(Pace · Plan B): 꼬리표 이름 + 그라디언트 문구 + 행동 버튼.
  Widget _suggestionPanel(ListSchedule item, ListTag tag) {
    final pace = tag.kind == ListTagKind.pace;
    void primary() {
      setState(() {
        _expanded.remove(item.id);
        if (!pace) {
          item.title = '기획안 마무리';
          item.tag = null;
        }
      });
      _toast(pace ? '출발 10분 전에 알려드릴게요' : '플랜 B로 바꿨어요');
    }

    void dismiss() => setState(() {
      _expanded.remove(item.id);
      item.tag = null;
    });

    return Container(
      margin: const EdgeInsets.only(left: 26, right: 1, top: 4, bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: tag.background,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag.label,
            style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: tag.color),
          ),
          SizedBox(width: pace ? 19 : 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListGradientText(
                  tag.message,
                  colors: [tag.color, tag.gradientEnd],
                  style: const TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionChip(label: tag.actions.first, color: tag.color, onTap: primary),
                    ),
                    if (tag.actions.length > 1) ...[
                      const SizedBox(width: 6),
                      _ActionChip(
                        label: tag.actions[1],
                        color: AppColors.gray06,
                        border: AppColors.divider,
                        onTap: dismiss,
                        horizontal: 24,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 제안 패널 안의 작은 흰 버튼(굴곡 8, 최소 높이 30, 12 SemiBold).
class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.color, required this.onTap, this.border, this.horizontal = 12});

  final String label;
  final Color color;
  final Color? border;
  final VoidCallback onTap;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: label,
      onTap: onTap,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 30),
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pressed ? AppColors.gray01 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border ?? color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }
}

/// 왼쪽으로 밀면 "이동 · 삭제"가 드러나는 일정 줄(07_07 이동/삭제).
class _SwipeRow extends StatefulWidget {
  const _SwipeRow({
    super.key,
    required this.child,
    required this.open,
    required this.onOpenChanged,
    required this.onMove,
    required this.onDelete,
    required this.showDivider,
  });

  final Widget child;
  final bool open;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final bool showDivider;

  @override
  State<_SwipeRow> createState() => _SwipeRowState();
}

class _SwipeRowState extends State<_SwipeRow> {
  static const _actionsWidth = ListSwipeActions.width;
  double? _drag;

  double get _offset => _drag ?? (widget.open ? -_actionsWidth : 0);

  @override
  Widget build(BuildContext context) {
    final offset = _offset;
    final revealed = offset < -1;
    return GestureDetector(
      onHorizontalDragStart: (_) => setState(() => _drag = _offset),
      onHorizontalDragUpdate: (d) =>
          setState(() => _drag = ((_drag ?? 0) + d.delta.dx).clamp(-_actionsWidth - 24, 0.0)),
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        final open = (_drag ?? 0) < -_actionsWidth / 2 || v < -300;
        setState(() => _drag = null);
        widget.onOpenChanged(open && v <= 300);
      },
      child: Container(
        decoration: BoxDecoration(
          border: widget.showDivider && !revealed ? const Border(bottom: BorderSide(color: AppColors.gray01)) : null,
        ),
        child: ClipRect(
          child: Stack(
            children: [
              if (revealed)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: ListSwipeActions(onMove: widget.onMove, onDelete: widget.onDelete),
                ),
              AnimatedContainer(
                duration: _drag == null ? const Duration(milliseconds: 220) : Duration.zero,
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(offset, 0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // 밀려난 줄은 회색 바탕 + 왼쪽 가장자리의 옅은 그림자
                  gradient: revealed
                      ? const LinearGradient(colors: [Color(0xFFE8E9EE), AppColors.gray01], stops: [0, 0.045])
                      : null,
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
