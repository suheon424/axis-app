import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/form_widgets.dart';

/// 07_10 일정 추가. 홈의 + 버튼으로 연다.
class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

const _labelGray = Color(0xFF6B7684);
const _valueColor = Color(0xFF1F2027);
const _repeatOptions = ['반복 안 함', '매일', '평일마다', '매주', '매월'];
const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

String _fmtDate(DateTime d) => '${d.month}월 ${d.day}일 (${_weekdays[d.weekday - 1]})';

String _fmtTime(TimeOfDay t) {
  final am = t.hour < 12;
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '${am ? 'AM' : 'PM'} ${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _title = TextEditingController();
  final _titleFocus = FocusNode();
  final _memo = TextEditingController();
  final _place = TextEditingController();
  final _transport = TextEditingController();
  final _planB = TextEditingController();

  DateTime _date = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  int _durationMin = 60;
  String _repeat = _repeatOptions.first;
  bool _detailsOpen = false;

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

  String get _timeText {
    final end = _end;
    final endText = (end.hour < 12) == (_start.hour < 12) ? _fmtTime(end).substring(3) : _fmtTime(end);
    return '${_fmtTime(_start)} – $endText';
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    var picked = _date;
    final ok = await _showPickerSheet(
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
    final ok = await _showPickerSheet(
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
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('반복', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 8),
              for (final o in _repeatOptions)
                InkWell(
                  onTap: () => Navigator.of(context).pop(o),
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            o,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: o == _repeat ? FontWeight.w700 : FontWeight.w500,
                              color: o == _repeat ? AppColors.primary : AppColors.text,
                            ),
                          ),
                        ),
                        if (o == _repeat)
                          SvgPicture.asset(
                            'assets/icons/ic_check.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (choice != null) setState(() => _repeat = choice);
  }

  Future<bool?> _showPickerSheet({required String title, required Widget child}) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
              SizedBox(height: 200, child: child),
              const SizedBox(height: 12),
              BrandButton(label: '확인', onPressed: () => Navigator.of(context).pop(true)),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final title = _title.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('"$title" 일정을 추가했어요.')));
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = _title.text.trim().isNotEmpty;
    final focused = _titleFocus.hasFocus;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 17),
              const _NavBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 24),
                  children: [
                    const Text(
                      '기본 일정',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    _FieldShell(
                      label: '제목',
                      labelColor: focused ? AppColors.primary : _labelGray,
                      lineColor: focused ? AppColors.primary : AppColors.line,
                      lineWidth: focused ? 2 : 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _title,
                              focusNode: _titleFocus,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _valueColor),
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: '일정 제목을 입력해 주세요',
                                hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.gray05),
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
                    const SizedBox(height: 14),
                    _SelectRow(label: '날짜', value: _fmtDate(_date), onTap: _pickDate),
                    const SizedBox(height: 14),
                    _SelectRow(label: '시간', value: _timeText, onTap: _pickTime),
                    const SizedBox(height: 14),
                    _SelectRow(label: '반복', value: _repeat, onTap: _pickRepeat),
                    const SizedBox(height: 20),
                    _DetailsBox(
                      open: _detailsOpen,
                      onToggle: () => setState(() => _detailsOpen = !_detailsOpen),
                      fields: [
                        ('설명', _memo),
                        ('위치', _place),
                        ('이동수단', _transport),
                        ('플랜 B(대체 일정)', _planB),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: BrandButton(label: '일정 추가하기', enabled: hasTitle, onPressed: _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 가운데 제목 "일정 추가"(#333) + 왼쪽 뒤로.
class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AppSizes.navHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('일정 추가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
          Positioned(left: 2, child: BackArrowButton()),
        ],
      ),
    );
  }
}

/// 라벨(13) + 높이 44 입력 줄 + 밑줄.
class _FieldShell extends StatelessWidget {
  const _FieldShell({
    required this.label,
    required this.labelColor,
    required this.lineColor,
    required this.lineWidth,
    required this.child,
  });

  final String label;
  final Color labelColor;
  final Color lineColor;
  final double lineWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w500, color: labelColor),
          child: Text(label),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lineColor, width: lineWidth))),
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
          labelColor: _labelGray,
          lineColor: AppColors.line,
          lineWidth: 1,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: _valueColor),
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset('assets/icons/ic_chevron_down.svg', width: 18, height: 18),
            ],
          ),
        ),
      ),
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
      decoration: BoxDecoration(color: AppColors.searchBg, borderRadius: BorderRadius.circular(8)),
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '상세 설정',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _valueColor),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '설명 · 위치 · 이동수단 · 플랜 B(대체 일정)',
                            style: TextStyle(fontSize: 13, color: Color(0xFF8B95A1)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: SvgPicture.asset('assets/icons/ic_chevron_down.svg', width: 20, height: 20),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        for (final (label, controller) in fields)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextField(
                              controller: controller,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _valueColor),
                              decoration: InputDecoration(
                                labelText: label,
                                labelStyle: const TextStyle(fontSize: 13, color: _labelGray),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.chipBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.chipBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.primary),
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
