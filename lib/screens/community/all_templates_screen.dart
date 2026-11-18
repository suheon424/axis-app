import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import '../my/my_widgets.dart';
import 'community_data.dart';
import 'community_widgets.dart';

/// 09-5 커뮤니티 · 전체 템플릿(205:10484): 09 "인기 계획 템플릿 · 전체보기".
/// 위 카테고리 칩(전체·공부·운동·습관·여행) + "전체 템플릿 128" · 정렬 드롭다운 + 템플릿 줄 목록.
class AllTemplatesScreen extends StatefulWidget {
  const AllTemplatesScreen({super.key, required this.onOpen});

  final void Function(CommunityTemplate template) onOpen;

  @override
  State<AllTemplatesScreen> createState() => _AllTemplatesScreenState();
}

class _AllTemplatesScreenState extends State<AllTemplatesScreen> {
  static const _chips = ['전체', '공부', '운동', '습관', '여행'];

  /// 칩 → 템플릿 카테고리 앞부분.
  static const _match = {'공부': '공부', '운동': '건강', '습관': '습관', '여행': '여행'};

  int _chip = 0;
  final Set<int> _bookmarks = {};

  List<CommunityTemplate> get _visible => _chip == 0
      ? allCommunityTemplates
      : allCommunityTemplates.where((t) => t.category.startsWith(_match[_chips[_chip]]!)).toList();

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final count = _chip == 0 ? allCommunityTemplateCount : visible.length;
    return MySubScaffold(
      title: '인기 계획 템플릿',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          Row(
            children: [
              for (var i = 0; i < _chips.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                _Chip(label: _chips[i], selected: i == _chip, onTap: () => setState(() => _chip = i)),
              ],
            ],
          ),
          const SizedBox(height: 46),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '전체 템플릿 ',
                    children: [
                      TextSpan(
                        text: '$count',
                        style: const TextStyle(color: AppColors.brand),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
              ),
              // Frame 124: "전체" 드롭다운(#EDEEF6 테두리, 굴곡 4).
              Container(
                constraints: const BoxConstraints(minWidth: 56, minHeight: 26),
                padding: const EdgeInsets.only(left: 8, right: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray02),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '전체',
                      style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.gray07),
                    ),
                    SizedBox(width: 2),
                    AxisIcon(KitIcon.chevronDownSmall, size: 15, color: AppColors.gray07),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.gray04),
          const SizedBox(height: 10),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: CommunityEmpty(
                icon: Icons.inbox_outlined,
                title: '아직 템플릿이 없어요',
                description: '다른 카테고리의 계획을 둘러보세요.',
              ),
            )
          else
            for (final (i, t) in visible.indexed)
              TemplateRow(
                template: t,
                first: i == 0,
                bookmarked: _bookmarks.contains(t.rank),
                onBookmark: () =>
                    setState(() => _bookmarks.contains(t.rank) ? _bookmarks.remove(t.rank) : _bookmarks.add(t.rank)),
                onTap: () => widget.onOpen(t),
              ),
        ],
      ),
    );
  }
}

/// chip/…: 높이 24 · 굴곡 6. 선택은 #191F28 채움 + 흰 글자, 나머지는 흰 바탕 + #DDDFEA 테두리.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minWidth: 56, minHeight: 24),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.text : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: selected ? AppColors.text : AppColors.chipBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.neutralText,
            ),
          ),
        ),
      ),
    );
  }
}
