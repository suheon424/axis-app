import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';

/// 07_10 일정 추가. 홈·일정 목록의 + 버튼으로 연다. 제목을 넣어야 "저장하기"가 파래진다.
/// [initialTitle]이 있으면 상세 시트의 "일정 수정"으로 연 것(제목 "일정 수정").
class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key, this.initialTitle, this.initialDate});

  final String? initialTitle;

  /// 없으면 오늘.
  final DateTime? initialDate;

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

const _repeatOptions = ['반복 안 함', '매일', '평일마다', '매주', '매월'];
const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

String _fmtDate(DateTime d) => '${d.month}월 ${d.day}일 (${_weekdays[d.weekday - 1]})';

(String, String) _clock(TimeOfDay t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return ('${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}', t.hour < 12 ? 'AM' : 'PM');
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  late final _title = TextEditingController(text: widget.initialTitle);
  final _titleFocus = FocusNode();
  final _memo = TextEditingController();
  final _place = TextEditingController();
  final _transport = TextEditingController();
  final _planB = TextEditingController();

  late DateTime _date = widget.initialDate ?? DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  int _durationMin = 60;
  String _repeat = _repeatOptions.first;
  bool _detailsOpen = false;

  bool get _editing => widget.initialTitle != null;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _titleFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_title, _memo, _place, _transport, _planB]) {
      c.dispose();
    }
    _titleFocus.dispose();
    super.dispose();
  }

  TimeOfDay get _end {
    final m = (_start.hour * 60 + _start.minute + _durationMin) % (24 * 60);
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }

  /// "09:00 – 10:00 AM" 또는 "11:00 AM – 12:00 PM".
  String get _timeText {
    final (s, sp) = _clock(_start);
    final (e, ep) = _clock(_end);
    return sp == ep ? '$s – $e $ep' : '$s $sp – $e $ep';
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    var picked = _date;
    final ok = await _pickerSheet(
      title: '날짜',
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _date,
        dateOrder: DatePickerDateOrder.ymd,
        onDateTimeChanged: (d) => picked = d,
      ),
    );
    if (ok == true) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    var picked = DateTime(2000, 1, 1, _start.hour, _start.minute);
    final ok = await _pickerSheet(
      title: '시작 시간 (1시간)',
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        minuteInterval: 5,
        initialDateTime: DateTime(2000, 1, 1, _start.hour, _start.minute - _start.minute % 5),
        onDateTimeChanged: (d) => picked = d,
      ),
    );
    if (ok == true) {
      setState(() {
        _start = TimeOfDay(hour: picked.hour, minute: picked.minute);
        _durationMin = 60;
      });
    }
  }

  Future<void> _pickRepeat() async {
    FocusScope.of(context).unfocus();
    final choice = await showAxisSheet<String>(
      context,
      title: '반복',
      builder: (ctx) => Column(
        children: [
          for (final o in _repeatOptions)
            PressBuilder(
              semanticLabel: o,
              scale: 1,
              onTap: () => Navigator.of(ctx).pop(o),
              builder: (context, pressed) => Container(
                constraints: const BoxConstraints(minHeight: 52),
                color: pressed ? AppColors.gray01 : Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        o,
                        style: AxisText.rowTitleMedium.copyWith(
                          color: o == _repeat ? AppColors.brand : AppColors.gray07,
                        ),
                      ),
                    ),
                    AxisRadio(selected: o == _repeat),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (choice != null) setState(() => _repeat = choice);
  }

  Future<bool?> _pickerSheet({required String title, required Widget child}) {
    return showAxisSheet<bool>(
      context,
      title: title,
      builder: (_) => SizedBox(height: 200, child: child),
      footer: (ctx) => AxisCtaButton(label: '확인', onPressed: () => Navigator.of(ctx).pop(true)),
    );
  }

  void _submit() {
    final title = _title.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(_editing ? '"$title" 일정을 수정했어요.' : '"$title" 일정을 추가했어요.')));
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = _title.text.trim().isNotEmpty;
    final focused = _titleFocus.hasFocus;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              AxisBackTitleBar(title: _editing ? '일정 수정' : '일정 추가'),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    const Text('기본 일정', style: AxisText.sectionTitle),
                    const SizedBox(height: 22),
                    _FieldShell(
                      label: '제목',
                      active: focused,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _title,
                              focusNode: _titleFocus,
                              textInputAction: TextInputAction.done,
                              style: _valueStyle,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: '일정 제목을 입력해 주세요',
                                hintStyle: _valueStyle.copyWith(fontWeight: FontWeight.w400, color: AppColors.gray04),
                              ),
                            ),
                          ),
                          if (hasTitle)
                            Semantics(
                              button: true,
                              label: '제목 지우기',
                              excludeSemantics: true,
                              onTap: _title.clear,
                              child: GestureDetector(
                                onTap: _title.clear,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: SvgPicture.asset('assets/icons/ic_clear.svg', width: 18, height: 18),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SelectRow(label: '날짜', value: _fmtDate(_date), onTap: _pickDate),
                    const SizedBox(height: 22),
                    _SelectRow(label: '시간', value: _timeText, onTap: _pickTime),
                    const SizedBox(height: 22),
                    _SelectRow(label: '반복', value: _repeat, onTap: _pickRepeat),
                    const SizedBox(height: 20),
                    _DetailsBox(
                      open: _detailsOpen,
                      onToggle: () => setState(() => _detailsOpen = !_detailsOpen),
                      fields: [('설명', _memo), ('위치', _place), ('이동수단', _transport), ('플랜 B(대체 일정)', _planB)],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSizes.ctaBottom),
                child: AxisCtaButton(label: '저장하기', enabled: hasTitle, onPressed: _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _valueStyle = TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.gray09);

/// 라벨(12) + 최소 높이 44 입력 줄 + 밑줄. [active]면 라벨·밑줄이 파랑.
class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.label, required this.child, this.active = false});

  final String label;
  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AxisText.caption.copyWith(
            fontFamily: 'Pretendard',
            color: active ? AppColors.brand : AppColors.gray06,
          ),
          child: Text(label),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: active ? AppColors.brand : AppColors.gray04, width: active ? 2 : 1),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    );
  }
}

/// 눌러서 시트에서 고르는 줄(날짜·시간·반복).
class _SelectRow extends StatelessWidget {
  const _SelectRow({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _FieldShell(
          label: label,
          child: Row(
            children: [
              Expanded(child: Text(value, style: _valueStyle)),
              const SizedBox(width: 8),
              const _Chevron(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/ic_chevron_down.svg',
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(AppColors.gray06, BlendMode.srcIn),
    );
  }
}

/// "상세 설정" 접이식 상자(설명 · 위치 · 이동수단 · 플랜 B).
class _DetailsBox extends StatelessWidget {
  const _DetailsBox({required this.open, required this.onToggle, required this.fields});

  final bool open;
  final VoidCallback onToggle;
  final List<(String, TextEditingController)> fields;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: open,
            label: '상세 설정',
            excludeSemantics: true,
            onTap: onToggle,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('상세 설정', style: AxisText.rowTitle),
                          SizedBox(height: 4),
                          Text('설명 · 위치 · 이동수단 · 플랜 B(대체 일정)', style: AxisText.caption),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const _Chevron(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        for (final (label, controller) in fields)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextField(
                              controller: controller,
                              style: AxisText.rowTitleMedium.copyWith(color: AppColors.gray07),
                              decoration: InputDecoration(
                                labelText: label,
                                labelStyle: AxisText.caption,
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.gray02),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.brand),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
