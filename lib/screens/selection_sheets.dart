import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/form_widgets.dart';
import '../widgets/kit/kit_buttons.dart';
import '../widgets/kit/selection.dart';
import '../widgets/kit/sheets.dart';

/// 5-1 시트의 "자주 선택하는 시간".
const prepQuickMinutes = [20, 30, 40, 60, 90];

/// 5-2 시트의 네 축. 각 축에서 하나씩 고른다.
const mbtiAxes = [
  (name: '에너지', options: [('E', '외향'), ('I', '내향')]),
  (name: '인식', options: [('S', '감각'), ('N', '직관')]),
  (name: '판단', options: [('T', '사고'), ('F', '감정')]),
  (name: '생활', options: [('J', '계획'), ('P', '즉흥')]),
];

/// MBTI 시트에서 "잘 모르겠어요"를 눌렀을 때 돌려주는 값.
const mbtiUnknown = '잘 모르겠어요';

/// 5-1 준비시간 시트. 10분 단위로 조절하고 고른 분(min)을 돌려준다.
Future<int?> showPrepTimeSheet(BuildContext context, {int? initial}) {
  return _showSheet<int>(context, (_) => _PrepTimeSheet(initial: initial ?? 40));
}

/// 5-2 MBTI 시트(선택 전 · 선택 완료). 네 글자 유형 또는 [mbtiUnknown]을 돌려준다.
Future<String?> showMbtiSheet(BuildContext context, {String? initial}) {
  return _showSheet<String>(context, (_) => _MbtiSheet(initial: initial));
}

Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    elevation: 0,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 320),
      reverseDuration: Duration(milliseconds: 240),
    ),
    builder: builder,
  );
}

/// 5-1·5-2 시트의 공통 틀: Sheet/Header(제목 + 닫기) 바로 아래 설명 14,
/// 16 띄우고 본문, [footerGap](20 이상) 띄우고 아래 버튼. 높이는 내용에 맞춘다.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.description,
    required this.body,
    required this.footer,
    this.footerGap = 32,
  });

  final String title;
  final String description;
  final Widget body;
  final Widget footer;
  final double footerGap;

  @override
  Widget build(BuildContext context) {
    return AxisSheetFrame(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AxisSheetHeader(title: title),
          Text(description, style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.body)),
        ],
      ),
      footer: footer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          body,
          SizedBox(height: footerGap - 20),
        ],
      ),
    );
  }
}

class _PrepTimeSheet extends StatefulWidget {
  const _PrepTimeSheet({required this.initial});

  final int initial;

  @override
  State<_PrepTimeSheet> createState() => _PrepTimeSheetState();
}

class _PrepTimeSheetState extends State<_PrepTimeSheet> {
  static const _min = 10;
  static const _max = 180;
  static const _step = 10;

  late int _minutes = widget.initial;

  void _change(int delta) => setState(() => _minutes = (_minutes + delta).clamp(_min, _max));

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: '평소 준비시간',
      description: '준비 시간을 반영해 출발 시간을 알려 드려요.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AxisStepper(
            value: '$_minutes분',
            caption: '10분 단위로 조절',
            onMinus: _minutes > _min ? () => _change(-_step) : null,
            onPlus: _minutes < _max ? () => _change(_step) : null,
          ),
          const SizedBox(height: 24),
          const Text(
            '자주 선택하는 시간',
            style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.body),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (final m in prepQuickMinutes) ...[
                if (m != prepQuickMinutes.first) const SizedBox(width: 8),
                Expanded(
                  child: OptionBox(
                    selected: _minutes == m,
                    selectedColor: AppColors.brandSoft,
                    label: '$m분',
                    onTap: () => setState(() => _minutes = m),
                    child: Text(
                      '$m분',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: _minutes == m ? AppColors.brand : AppColors.body,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      footer: AxisCtaButton(label: '선택 완료', onPressed: () => Navigator.of(context).pop(_minutes)),
    );
  }
}

class _MbtiSheet extends StatefulWidget {
  const _MbtiSheet({this.initial});

  final String? initial;

  @override
  State<_MbtiSheet> createState() => _MbtiSheetState();
}

class _MbtiSheetState extends State<_MbtiSheet> {
  /// 축마다 고른 글자. 아직 안 골랐으면 null.
  late final List<String?> _picked = List.generate(mbtiAxes.length, (i) {
    final initial = widget.initial;
    if (initial == null || initial.length != mbtiAxes.length) return null;
    final letter = initial[i];
    return mbtiAxes[i].options.any((o) => o.$1 == letter) ? letter : null;
  });

  bool get _complete => _picked.every((p) => p != null);

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'MBTI',
      description: '성향에 맞춰 일정 추천 방식을 바꿔 드려요.',
      body: Column(
        children: [
          for (var i = 0; i < mbtiAxes.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    mbtiAxes[i].name,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.36,
                      fontWeight: FontWeight.w500,
                      color: AppColors.body,
                    ),
                  ),
                ),
                for (final (letter, meaning) in mbtiAxes[i].options) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MbtiOption(
                      letter: letter,
                      meaning: meaning,
                      selected: _picked[i] == letter,
                      onTap: () => setState(() => _picked[i] = letter),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
      footerGap: 24,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.chipBorder)),
            ),
            child: Row(
              children: [
                const Text('선택한 유형', style: _resultLabel),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _complete ? _picked.join() : '아직 선택하지 않았어요',
                    textAlign: TextAlign.right,
                    style: _complete
                        ? _resultLabel.copyWith(color: AppColors.brand)
                        : const TextStyle(fontSize: 14, height: 1.4, color: AppColors.gray05),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AxisSplitButton(
            leftLabel: mbtiUnknown,
            rightLabel: '선택 완료',
            rightEnabled: _complete,
            onLeft: () => Navigator.of(context).pop(mbtiUnknown),
            onRight: () => Navigator.of(context).pop(_picked.join()),
          ),
        ],
      ),
    );
  }
}

const _resultLabel = TextStyle(
  fontSize: 16,
  height: 1.4,
  letterSpacing: -0.32,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

class _MbtiOption extends StatelessWidget {
  const _MbtiOption({required this.letter, required this.meaning, required this.selected, required this.onTap});

  final String letter;
  final String meaning;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OptionBox(
      selected: selected,
      onTap: onTap,
      label: '$letter $meaning',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letter,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.brand : AppColors.gray07,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            meaning,
            style: TextStyle(fontSize: 14, height: 1.4, color: selected ? AppColors.brand : AppColors.body),
          ),
        ],
      ),
    );
  }
}
