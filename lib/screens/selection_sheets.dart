import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/buttons.dart';
import '../widgets/form_widgets.dart';

const prepTimeOptions = [
  ['30분 이내', '1시간 이내', '1시간 30분 이내'],
  ['2시간 이내', '2시간 30분 이내', '3시간 이내'],
  ['3시간 30분 이내', '4시간 이내', '그 외 시간'],
];

/// 디자인의 칩 폭(98 / 146)을 줄마다 그대로 따른다. null은 남은 폭을 채운다.
const _prepTimeWidths = [
  [98.0, 98.0, null],
  [98.0, null, 98.0],
  [146.0, 98.0, 98.0],
];

const mbtiOptions = [
  'ISTP', 'ISTJ', 'ISFP', 'ISFJ',
  'INFJ', 'INFP', 'INTJ', 'INTP',
  'ENFP', 'ENFJ', 'ENTP', 'ENTJ',
  'ESTP', 'ESTJ', 'ESFJ', 'ESFP',
];

/// 06 · 준비시간 선택 시트.
Future<String?> showPrepTimeSheet(BuildContext context, {String? initial}) {
  return _showSheet(
    context,
    builder: (_) => _SelectionSheet(
      title: '준비시간 선택',
      initial: initial,
      horizontalPadding: 16,
      buttonPadding: 12,
      gridBuilder: (selected, onSelect) => Column(
        children: [
          for (var r = 0; r < prepTimeOptions.length; r++) ...[
            if (r > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var c = 0; c < prepTimeOptions[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: 8),
                  _sized(
                    _prepTimeWidths[r][c],
                    SelectChip(
                      label: prepTimeOptions[r][c],
                      selected: selected == prepTimeOptions[r][c],
                      onTap: () => onSelect(prepTimeOptions[r][c]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _sized(double? width, Widget child) =>
    width == null ? Expanded(child: child) : SizedBox(width: width, child: child);

/// 09 · MBTI 선택 시트.
Future<String?> showMbtiSheet(BuildContext context, {String? initial}) {
  return _showSheet(
    context,
    builder: (_) => _SelectionSheet(
      title: 'MBTI 선택',
      initial: initial,
      horizontalPadding: 20,
      buttonPadding: 20,
      gridBuilder: (selected, onSelect) => GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 39,
        children: [
          for (final m in mbtiOptions)
            SelectChip(label: m, selected: selected == m, onTap: () => onSelect(m)),
        ],
      ),
    ),
  );
}

Future<String?> _showSheet(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<String>(
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

class _SelectionSheet extends StatefulWidget {
  const _SelectionSheet({
    required this.title,
    required this.gridBuilder,
    required this.horizontalPadding,
    required this.buttonPadding,
    this.initial,
  });

  final String title;
  final String? initial;
  final double horizontalPadding;
  final double buttonPadding;
  final Widget Function(String? selected, ValueChanged<String> onSelect) gridBuilder;

  @override
  State<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> {
  late String? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Color(0x1A000000), offset: Offset(0, -4), blurRadius: 10)],
      ),
      padding: EdgeInsets.only(bottom: 38 + safeBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 79,
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 24,
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 16,
                  child: IconButton(
                    tooltip: '닫기',
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: SvgPicture.asset('assets/icons/ic_close.svg', width: 34, height: 34),
                  ),
                ),
              ],
            ),
          ),
          // 디자인에서 선택지 영역은 시트 상단 79px부터 버튼(354px) 전까지다.
          SizedBox(
            height: 275,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                child: widget.gridBuilder(_selected, (v) => setState(() => _selected = v)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.buttonPadding),
            child: BrandButton(
              label: '시작하기',
              fontSize: 18.68,
              fontWeight: FontWeight.w600,
              enabled: _selected != null,
              onPressed: () => Navigator.of(context).pop(_selected),
            ),
          ),
        ],
      ),
    );
  }
}
