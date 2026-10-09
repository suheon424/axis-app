import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_widgets.dart';

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

/// 5-1 · 평소 준비시간 시트. 10분 단위로 조절하고 고른 분(min)을 돌려준다.
Future<int?> showPrepTimeSheet(BuildContext context, {int? initial}) {
  return _showSheet<int>(context, (_) => _PrepTimeSheet(initial: initial ?? 40));
}

/// 5-2 · MBTI 시트. 네 글자 유형 또는 [mbtiUnknown]을 돌려준다.
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

/// 개선안 ③의 공통 시트 틀: 높이 495 고정, 위 굴곡 16, 제목 + 닫기 + 설명, 아래 버튼.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.description, required this.body, required this.footer});

  final String title;
  final String description;
  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 495 + safeBottom,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color(0x1F000000), offset: Offset(0, -4), blurRadius: 24)],
      ),
      padding: EdgeInsets.fromLTRB(20, 22, 20, 28 + safeBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 32,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w700, color: AppColors.gray07),
                  ),
                ),
                // 아이콘 24, 보이는 영역 32. 탭 영역은 44로 넓힌다.
                SizedBox(
                  width: 32,
                  height: 32,
                  child: OverflowBox(
                    maxWidth: 44,
                    maxHeight: 44,
                    child: IconButton(
                      tooltip: '닫기',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: SvgPicture.asset('assets/icons/ic_close.svg', width: 24, height: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(description, style: const TextStyle(fontSize: 14, color: AppColors.body)),
          const SizedBox(height: 24),
          body,
          const Spacer(),
          footer,
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
      description: '준비 시간에 맞춰서 이동 동선을 제안 및 추천해드려요.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppColors.stepperBg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _StepButton(
                  icon: 'assets/icons/ic_minus.svg',
                  tooltip: '10분 줄이기',
                  onTap: _minutes > _min ? () => _change(-_step) : null,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(anim), child: child),
                        ),
                        child: Text(
                          '$_minutes분',
                          key: ValueKey(_minutes),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.gray07),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '10분 단위로 조절',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.caption),
                      ),
                    ],
                  ),
                ),
                _StepButton(
                  icon: 'assets/icons/ic_plus.svg',
                  tooltip: '10분 늘리기',
                  onTap: _minutes < _max ? () => _change(_step) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '자주 선택하는 시간',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.body),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final m in prepQuickMinutes) ...[
                if (m != prepQuickMinutes.first) const SizedBox(width: 8),
                Expanded(
                  child: OptionBox(
                    selected: _minutes == m,
                    onTap: () => setState(() => _minutes = m),
                    child: Text(
                      '$m분',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: _minutes == m ? AppColors.primary : AppColors.body,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      footer: BrandButton(label: '선택 완료', onPressed: () => Navigator.of(context).pop(_minutes)),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, required this.onTap});

  final String icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: AnimatedOpacity(
          opacity: onTap == null ? 0.35 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.chipBorder),
            ),
            child: SvgPicture.asset(icon, width: 24, height: 24),
          ),
        ),
      ),
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
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.body),
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
      footer: Column(
        children: [
          Container(
            height: 52,
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.chipBorder))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('선택한 유형', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                Text(
                  [for (final p in _picked) p ?? '—'].join(_complete ? '' : ' '),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: _complete ? AppColors.primary : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlineButton(label: mbtiUnknown, onPressed: () => Navigator.of(context).pop(mbtiUnknown)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BrandButton(
                  label: '선택 완료',
                  enabled: _complete,
                  onPressed: () => Navigator.of(context).pop(_picked.join()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.gray07,
            ),
          ),
          const SizedBox(width: 6),
          Text(meaning, style: TextStyle(fontSize: 13, color: selected ? AppColors.primary : AppColors.body)),
        ],
      ),
    );
  }
}
