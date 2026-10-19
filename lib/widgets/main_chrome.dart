import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 07 이후 메인 화면들의 하단 탭(홈 · Ai플래너 · 탐색 · 이벤트 · 마이).
enum MainTab { home, planner, explore, event, my }

extension on MainTab {
  String get label => const ['홈', 'Ai플래너', '탐색', '이벤트', '마이'][index];
  String get icon => const ['home', 'planner', 'explore', 'event', 'my'][index];
}

/// 어두운 하단 탭 바(#121212). 선택된 탭은 흰 굵은 글씨와 파란 빛 배경.
/// [onTap]이 없으면 아직 없는 탭은 "준비 중" 안내를 띄운다.
class AxisTabBar extends StatelessWidget {
  const AxisTabBar({super.key, required this.current, this.onTap});

  final MainTab current;
  final ValueChanged<MainTab>? onTap;

  static const background = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: background,
        boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 5, offset: Offset(0, -2))],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 2, bottom: bottom > 0 ? bottom : 8),
        child: Row(
          children: [
            for (final tab in MainTab.values)
              Expanded(
                child: _TabItem(
                  tab: tab,
                  selected: tab == current,
                  onTap: () {
                    if (onTap != null) {
                      onTap!(tab);
                    } else if (tab != current) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text('${tab.label}은(는) 준비 중이에요.')));
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.tab, required this.selected, required this.onTap});

  final MainTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: selected
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x4D474E58), Color(0x4D474E58), Color(0x4D0057ED)],
                    stops: [0, 0.38, 1],
                  ),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/tab/${tab.icon}_${selected ? 'on' : 'off'}.svg', width: 23, height: 23),
              const SizedBox(height: 4),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF494949),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
