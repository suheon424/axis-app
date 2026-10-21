import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/main_chrome.dart';
import 'add_schedule_screen.dart';
import 'list_ai.dart';
import 'list_data.dart';
import 'list_parts.dart';
import 'list_sheets.dart';
import 'map_screen.dart';

/// 07_05 일정 목록(Todo). 헤더의 "J모드" 칩으로 07_06 J모드(시간 + AI 꼬리표)와 오간다.
/// - 체크박스로 완료 표시, 6개를 모두 체크하면 배지 획득 팝업(pop_07_05).
/// - 일정을 누르면 상세 시트(07_08) → 더보기(07_08-1) → 삭제 확인(07_08-2).
/// - 일정을 왼쪽으로 밀면 날짜 변경 · 삭제(07_07).
/// - "틀어진 일정 맞추기" → AI 분석 중(07_05-1) → AI 일정 제안(07_05-2).
class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

enum _Filter { all, todo, done }

extension on _Filter {
  String get label => const ['전체', '미완료', '완료'][index];
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  static const _bg = Color(0xFFF4F5FA);
  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  static const _scheduleDay = 23;

  final List<ListSchedule> _items = listSampleSchedules();
  bool _jMode = false;
  _Filter _filter = _Filter.all;
  int _selectedDay = _scheduleDay;
  int? _openSwipeId;
  final Set<int> _expanded = {};
  bool _badgeShown = false;

  List<ListSchedule> get _dayItems => _selectedDay == _scheduleDay ? _items : const [];

  List<ListSchedule> get _visible => switch (_filter) {
    _Filter.all => _dayItems,
    _Filter.todo => _dayItems.where((e) => !e.done).toList(),
    _Filter.done => _dayItems.where((e) => e.done).toList(),
  };

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
        if (mounted) showListBadgePopup(context);
      });
    }
  }

  Future<void> _openDetail(ListSchedule item) async {
    setState(() => _openSwipeId = null);
    final action = await showListDetailSheet(context, item);
    if (!mounted || action == null) return;
    switch (action) {
      case ListSheetAction.edit:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddScheduleScreen()));
      case ListSheetAction.changeDate:
        await _changeDate(item);
      case ListSheetAction.delete:
        await _confirmDelete(item);
    }
  }

  Future<void> _changeDate(ListSchedule item) async {
    setState(() => _openSwipeId = null);
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
    if (picked.month == 11 && picked.day == _scheduleDay && picked.year == 2026) return;
    setState(() => _items.remove(item));
    _toast('‘${item.title}’을(를) ${picked.month}월 ${picked.day}일로 옮겼어요.');
  }

  Future<void> _confirmDelete(ListSchedule item) async {
    setState(() => _openSwipeId = null);
    final scope = await showListDeleteDialog(context);
    if (!mounted || scope == null) return;
    setState(() {
      _items.remove(item);
      _expanded.remove(item.id);
    });
    _toast(scope == ListDeleteScope.onlyThis ? '‘${item.title}’ 일정을 삭제했어요.' : '‘${item.title}’ 이후 일정을 모두 삭제했어요.');
  }

  Future<void> _runAi() async {
    setState(() => _openSwipeId = null);
    final finished = await showListAiAnalyzing(context);
    if (!mounted || finished != true) return;
    final apply = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const ListAiSuggestionScreen()));
    if (!mounted || apply != true) return;
    setState(() {
      ListSchedule? byId(int id) => _items.where((e) => e.id == id).firstOrNull;
      final lunch = byId(3);
      final bill = byId(6);
      if (lunch != null) {
        lunch
          ..time = 'PM 01:00'
          ..endTime = 'PM 02:00';
      }
      if (bill != null) {
        bill
          ..time = 'PM 02:35'
          ..endTime = 'PM 02:45';
        // 관리비 납부를 팀 점심 바로 뒤로 옮긴다.
        _items.remove(bill);
        final at = lunch == null ? _items.length : _items.indexOf(lunch) + 1;
        _items.insert(at, bill);
      }
    });
    _toast('제안대로 일정을 맞췄어요.');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: _bg),
      child: Scaffold(
        backgroundColor: _bg,
        bottomNavigationBar: const AxisTabBar(current: MainTab.home, light: true),
        body: SafeArea(
          bottom: false,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _openSwipeId == null ? null : () => setState(() => _openSwipeId = null),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _nav(),
                  const SizedBox(height: 14),
                  _calendarCard(),
                  const SizedBox(height: 10),
                  _listSection(),
                  const SizedBox(height: 16),
                  ListFixButton(onTap: _runAi),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nav() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Todo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          Positioned(
            left: 4,
            child: ListIconButton(
              asset: 'assets/icons/ic_arrow_left.svg',
              label: '뒤로',
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            right: 7,
            child: ListIconButton(
              asset: 'assets/icons/list_plus.svg',
              label: '일정 추가',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddScheduleScreen())),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── 위 카드: 인사 배너 · 월 · 주간 달력
  Widget _calendarCard() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(colors: [AppColors.blue01, Color(0xFFEFF8FF)], stops: [0, 0.56]),
            ),
            child: const Row(
              children: [
                Text(
                  '황수현 님',
                  style: TextStyle(fontSize: 12, height: 2, fontWeight: FontWeight.w700, color: AppColors.gray09),
                ),
                SizedBox(width: 16),
                Flexible(
                  child: Text(
                    '지난달보다 달성률이 높아요. 잘 실천하고 있어요!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          Padding(
            padding: const EdgeInsets.only(left: 23),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/list_cal_prev.svg', width: 26, height: 26),
                const SizedBox(width: 16),
                const Text(
                  '2026년 11월',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gray09),
                ),
                const SizedBox(width: 16),
                SvgPicture.asset('assets/icons/list_cal_next.svg', width: 26, height: 26),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), child: _week()),
        ],
      ),
    );
  }

  Widget _week() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = constraints.maxWidth / 7;
        final selected = _selectedDay - 22;
        return SizedBox(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 고른 요일을 감싸는 검은 기둥(52 × 87)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: cell * selected + cell / 2 - 26,
                top: -7,
                child: Container(
                  width: 52,
                  height: 87,
                  decoration: BoxDecoration(color: AppColors.gray09, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 7; i++)
                        SizedBox(
                          width: cell,
                          height: 20,
                          child: Center(
                            child: Text(
                              _weekdays[i],
                              style: TextStyle(
                                fontSize: 12,
                                color: i == selected ? Colors.white : const Color(0xFFA3A7B2),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 0; i < 7; i++)
                        SizedBox(
                          width: cell,
                          height: 50,
                          child: Center(child: _dayCell(22 + i)),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dayCell(int day) {
    final selected = day == _selectedDay;
    final hasSchedule = day == _scheduleDay;
    return Semantics(
      button: true,
      selected: selected,
      label: '11월 $day일',
      excludeSemantics: true,
      onTap: () => setState(() => _selectedDay = day),
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedDay = day;
          _openSwipeId = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFCCDDFB) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              // 숫자는 요일 글자와 같은 세로줄에 오도록 칸 가운데에 둔다.
              Center(
                child: Text(
                  '$day',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: -1,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? Colors.black : AppColors.gray04,
                  ),
                ),
              ),
              if (hasSchedule)
                Positioned(
                  left: 31,
                  top: 5,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(color: CubeColors.red, shape: BoxShape.circle),
                  ),
                ),
              if (hasSchedule && selected)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 31,
                  child: Container(
                    height: 1.56,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(1)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── 아래 카드: 목록/지도 탭 · 헤더 · 일정
  Widget _listSection() {
    final visible = _visible;
    final weekday = _weekdays[(_selectedDay - 22) % 7];
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          _tabs(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$_selectedDay일 ($weekday)',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray09),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '일정 ${_dayItems.length}건',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _jChip(),
                const SizedBox(width: 8),
                _filterDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: visible.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('이 날은 일정이 없어요', style: TextStyle(fontSize: 14, color: AppColors.caption)),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: _jMode ? 16 : 20),
                    child: Column(
                      children: [
                        for (var i = 0; i < visible.length; i++)
                          _row(visible[i], _items.indexOf(visible[i]) + 1, isLast: i == visible.length - 1),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    Widget tab(String label, bool selected, VoidCallback? onTap) {
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 175,
            height: 40, // 아래 회색 선 1과 합쳐 탭 높이 41(피그마)
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: selected ? AppColors.gray07 : Colors.transparent, width: 2)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                height: 21 / 16,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.gray07 : AppColors.gray03,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 41,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          tab('목록', true, null),
          tab('지도', false, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MapScreen()))),
        ],
      ),
    );
  }

  Widget _jChip() {
    void toggle() => setState(() {
      _jMode = !_jMode;
      _openSwipeId = null;
    });
    return Semantics(
      button: true,
      toggled: _jMode,
      label: 'J모드',
      excludeSemantics: true,
      onTap: toggle,
      child: Pressable(
        onTap: toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 25,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _jMode ? AppColors.primary : AppColors.gray02,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'J모드',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _jMode ? Colors.white : AppColors.gray07,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterDropdown() {
    return PopupMenuButton<_Filter>(
      tooltip: '보기 필터',
      initialValue: _filter,
      onSelected: (f) => setState(() => _filter = f),
      position: PopupMenuPosition.under,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.divider),
      ),
      itemBuilder: (_) => [
        for (final f in _Filter.values)
          PopupMenuItem(
            value: f,
            height: 40,
            child: Text(
              f.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: f == _filter ? FontWeight.w700 : FontWeight.w500,
                color: f == _filter ? AppColors.primary : AppColors.gray07,
              ),
            ),
          ),
      ],
      child: Container(
        height: 25,
        constraints: const BoxConstraints(minWidth: 55),
        padding: const EdgeInsets.only(left: 7, right: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray03),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _filter.label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray07),
            ),
            const SizedBox(width: 2),
            SvgPicture.asset('assets/icons/list_dropdown.svg', width: 15, height: 15),
          ],
        ),
      ),
    );
  }

  Widget _row(ListSchedule item, int number, {required bool isLast}) {
    return _SwipeRow(
      key: ValueKey('row-${item.id}'),
      open: _openSwipeId == item.id,
      onOpenChanged: (open) => setState(() => _openSwipeId = open ? item.id : null),
      onChangeDate: () => _changeDate(item),
      onDelete: () => _confirmDelete(item),
      showDivider: !isLast,
      child: _jMode ? _jRowContent(item, number) : _rowContent(item, number),
    );
  }

  Widget _rowContent(ListSchedule item, int number) {
    return Semantics(
      button: true,
      label: '${item.title} 상세 보기',
      onTap: () => _openDetail(item),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openDetail(item),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              SizedBox(
                width: 17,
                child: Text(
                  '$number',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray09),
                ),
              ),
              Transform.translate(
                offset: const Offset(13, 0),
                child: ListCheckbox(checked: item.done, label: item.title, onTap: () => _toggle(item)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jRowContent(ListSchedule item, int number) {
    final tag = item.tag;
    final expanded = tag != null && _expanded.contains(item.id);
    void toggleTag() => setState(() => expanded ? _expanded.remove(item.id) : _expanded.add(item.id));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  SizedBox(
                    width: 17,
                    child: Text(
                      '$number',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 9),
                  SizedBox(
                    width: 56,
                    child: Text(
                      item.time,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF919191)),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
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
                              onTap: toggleTag,
                              child: Container(
                                height: 19,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: tag.background,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: tag.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(13, 0),
                    child: ListCheckbox(checked: item.done, label: item.title, jMode: true, onTap: () => _toggle(item)),
                  ),
                ],
              ),
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
    );
  }

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
      _toast(pace ? '출발 10분 전에 알려드릴게요.' : '플랜 B로 바꿨어요: 회의 전 기획안 마무리하기');
    }

    void dismiss() => setState(() {
      _expanded.remove(item.id);
      item.tag = null;
    });

    return Container(
      margin: const EdgeInsets.only(left: 27, right: 6, bottom: 16),
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
            style: TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w600, color: tag.color),
          ),
          SizedBox(width: pace ? 19 : 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListGradientText(
                  tag.message,
                  colors: [tag.color, tag.gradientEnd],
                  style: const TextStyle(fontSize: 12, height: 1.5, letterSpacing: 0.2, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _ActionChip(
                        label: tag.actions.first,
                        color: tag.color,
                        border: tag.color.withValues(alpha: 0.5),
                        onTap: primary,
                      ),
                    ),
                    if (tag.actions.length > 1) ...[
                      const SizedBox(width: 6),
                      _ActionChip(
                        label: tag.actions[1],
                        color: const Color(0xFF8B95A1),
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.color,
    required this.border,
    required this.onTap,
    this.horizontal = 12,
  });

  final String label;
  final Color color;
  final Color border;
  final VoidCallback onTap;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ),
    );
  }
}

/// 왼쪽으로 밀면 "날짜 변경 · 삭제"가 드러나는 일정 줄(07_07 Swipe).
class _SwipeRow extends StatefulWidget {
  const _SwipeRow({
    super.key,
    required this.child,
    required this.open,
    required this.onOpenChanged,
    required this.onChangeDate,
    required this.onDelete,
    required this.showDivider,
  });

  final Widget child;
  final bool open;
  final ValueChanged<bool> onOpenChanged;
  final VoidCallback onChangeDate;
  final VoidCallback onDelete;
  final bool showDivider;

  @override
  State<_SwipeRow> createState() => _SwipeRowState();
}

class _SwipeRowState extends State<_SwipeRow> {
  static const _actionsWidth = 160.0;
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
        final open = (_drag ?? 0) < -_actionsWidth / 2 || d.primaryVelocity! < -300;
        final close = d.primaryVelocity! > 300;
        setState(() => _drag = null);
        widget.onOpenChanged(open && !close);
      },
      child: Container(
        decoration: BoxDecoration(
          border: widget.showDivider && !revealed ? const Border(bottom: BorderSide(color: AppColors.gray02)) : null,
        ),
        child: ClipRect(
          child: Stack(
            children: [
              if (revealed)
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0xFFF4F5FA),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _action('날짜 변경', AppColors.gray06, widget.onChangeDate),
                          _action('삭제', CubeColors.red, widget.onDelete),
                        ],
                      ),
                    ),
                  ),
                ),
              AnimatedContainer(
                duration: _drag == null ? const Duration(milliseconds: 220) : Duration.zero,
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(offset, 0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // 밀려난 줄은 회색 바탕 + 왼쪽 가장자리의 옅은 그림자
                  gradient: revealed
                      ? const LinearGradient(colors: [Color(0xFFE8E9EE), Color(0xFFF4F5FA)], stops: [0, 0.045])
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

  Widget _action(String label, Color color, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 80,
          color: color,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
