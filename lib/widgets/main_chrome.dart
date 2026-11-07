import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 07 이후 메인 화면들의 하단 탭(홈 · AI 플래너 · 탐색 · 이벤트 · 마이).
enum MainTab { home, planner, explore, event, my }

extension MainTabLabel on MainTab {
  String get label => const ['홈', 'AI 플래너', '탐색', '이벤트', '마이'][index];
  String get _icon => const ['home', 'planner', 'explore', 'event', 'my'][index];
}

/// 탭마다 첫 화면을 만드는 함수. main.dart에서 등록한다(화면 파일끼리 서로 import하지 않게).
abstract final class MainTabRouter {
  static final Map<MainTab, WidgetBuilder> builders = {};

  /// 지금까지 쌓인 화면을 모두 걷어내고 [tab]의 첫 화면으로 바꾼다(전환 효과 없음).
  static void open(BuildContext context, MainTab tab) {
    final builder = builders[tab];
    if (builder == null) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(pageBuilder: (c, _, _) => builder(c), transitionDuration: Duration.zero),
      (_) => false,
    );
  }
}

/// 하단 탭 바(피그마 Tab Bar 130:9415 · Bottom Navigation 130:9742).
/// 리디자인에서는 모든 화면이 흰 바: 위 1px #CCD1DD 선 + 옅은 그림자, 높이 58(+ 홈 인디케이터 영역).
/// 선택된 탭은 검정 아이콘(파란 사선) + 12 SemiBold #181920, 나머지는 #CCD1DD 아이콘 + 12 Regular #8B95A1.
/// 탭을 바꾸면 새로 선택된 칸이 위아래로 한 번 뒤집히듯 넘어간다(Flip Shade).
/// [onTap]이 없으면 [MainTabRouter]에 등록된 탭 첫 화면으로 바꾸고, 아직 없는 탭은 "준비 중" 안내를 띄운다.
class AxisTabBar extends StatelessWidget {
  const AxisTabBar({super.key, required this.current, this.onTap, this.light = true});

  final MainTab current;
  final ValueChanged<MainTab>? onTap;

  /// 예전 어두운 바와의 호환용. 리디자인에서는 값과 상관없이 항상 흰 바로 그린다.
  final bool light;

  static const background = Colors.white;
  static const lightBackground = Colors.white;
  static const height = 58.0;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: Color(0xFFCCD1DD), width: 0.5)),
        boxShadow: [BoxShadow(color: Color(0x0F000A2B), blurRadius: 10, offset: Offset(0, -2))],
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
                    } else if (tab != current && MainTabRouter.builders[tab] != null) {
                      MainTabRouter.open(context, tab);
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
        child: SizedBox(
          height: 56,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: selected ? 1 : 0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              // 선택될 때 0→1: 가운데(0.5)에서 칸이 옆으로 누운 것처럼 보였다가 새 상태로 펼쳐진다.
              final flip = math.sin(t * math.pi) * 0.9;
              final on = t >= 0.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(flip * math.pi / 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/tab/${tab._icon}_light_${on ? 'on' : 'off'}.svg',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tab.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                        color: on ? const Color(0xFF181920) : const Color(0xFF8B95A1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
