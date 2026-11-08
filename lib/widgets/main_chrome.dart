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

  /// 다음에 그려질 탭 바가 어느 탭에서 넘어왔는지. 새 화면의 탭 바가 한 번 읽고 지운다.
  static MainTab? _from;

  /// 지금까지 쌓인 화면을 모두 걷어내고 [tab]의 첫 화면으로 바꾼다(화면 전환 효과 없음).
  /// [from]을 주면 새 화면의 탭 바가 [from] → [tab]으로 넘어가는 모션을 보여 준다.
  static void open(BuildContext context, MainTab tab, {MainTab? from}) {
    final builder = builders[tab];
    if (builder == null) return;
    _from = from;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(pageBuilder: (c, _, _) => builder(c), transitionDuration: Duration.zero),
      (_) => false,
    );
  }

  static MainTab? _takeFrom(MainTab current) {
    final from = _from;
    _from = null;
    return from == current ? null : from;
  }
}

/// 하단 탭 바(피그마 Tab Bar 130:9415 · Bottom Navigation 130:9742).
/// 기본은 흰 바(위 1px #CCD1DD 선 + 옅은 그림자, 높이 58 + 홈 인디케이터 영역). 07_01 홈은 [light]=false로 블랙모드 바.
/// 선택된 탭은 검정 아이콘(파란 사선) + 12 SemiBold #181920, 나머지는 #CCD1DD 아이콘 + 12 Regular #8B95A1.
/// 탭을 바꾸면 피그마 Smart Animate(0.46초, ease in-out)처럼 칸마다 꺼진/켜진 버튼이 위아래로 굴러간다:
/// 새 탭은 꺼진 버튼이 위로 빠지고 켜진 버튼이 아래에서 올라오며(그림자가 걷힘), 이전 탭은 그 반대로 내려간다.
/// [onTap]이 없으면 [MainTabRouter]에 등록된 탭 첫 화면으로 바꾸고, 아직 없는 탭은 "준비 중" 안내를 띄운다.
class AxisTabBar extends StatefulWidget {
  const AxisTabBar({super.key, required this.current, this.onTap, this.light = true});

  final MainTab current;
  final ValueChanged<MainTab>? onTap;

  /// true면 흰 바, false면 블랙모드 바(07_01 홈_목록 · 홈_달성률: #121212 바탕, 위 1px #1F2027 선,
  /// 켜진 탭은 흰 아이콘·흰 SemiBold 글씨, 꺼진 탭은 #494949).
  final bool light;

  static const background = Colors.white;
  static const lightBackground = Colors.white;
  static const darkBackground = Color(0xFF121212);
  static const height = 58.0;

  /// Tab Bar(130:9415)는 58 바 + 34 Home Indicator = 92. 기기가 아래 여백을 알려주지 않는 웹에서도 34를 둔다.
  static const homeIndicator = 34.0;

  @override
  State<AxisTabBar> createState() => _AxisTabBarState();
}

class _AxisTabBarState extends State<AxisTabBar> {
  late final MainTab? _from = MainTabRouter._takeFrom(widget.current);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final current = widget.current;
    final light = widget.light;
    return DecoratedBox(
      decoration: light
          ? const BoxDecoration(
              color: AxisTabBar.background,
              border: Border(top: BorderSide(color: Color(0xFFCCD1DD), width: 0.5)),
              boxShadow: [BoxShadow(color: Color(0x0F000A2B), blurRadius: 10, offset: Offset(0, -2))],
            )
          : const BoxDecoration(
              color: AxisTabBar.darkBackground,
              border: Border(top: BorderSide(color: Color(0xFF1F2027))),
              boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, -2))],
            ),
      child: Padding(
        padding: EdgeInsets.only(top: 2, bottom: bottom > AxisTabBar.homeIndicator ? bottom : AxisTabBar.homeIndicator),
        child: Row(
          children: [
            for (final tab in MainTab.values)
              Expanded(
                child: _TabItem(
                  tab: tab,
                  light: light,
                  selected: tab == current,
                  // 이 화면이 다른 탭에서 넘어왔으면 처음 그릴 때 이전 상태에서 출발한다.
                  wasSelected: _from == null ? tab == current : tab == _from,
                  onTap: () {
                    if (widget.onTap != null) {
                      widget.onTap!(tab);
                    } else if (tab != current && MainTabRouter.builders[tab] != null) {
                      MainTabRouter.open(context, tab, from: current);
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

/// 탭 한 칸(Bottom Navigation/Item). 56 높이 칸 안에 꺼진 버튼과 켜진 버튼을 위아래로 겹쳐 두고
/// 선택 정도(0~1)에 따라 60씩 굴린다. 켜진 버튼이 올라오는 동안 Flip Shade(위가 진한 그림자)와
/// Fold Edge(윗변 1px 선)가 걷힌다.
class _TabItem extends StatefulWidget {
  const _TabItem({
    required this.tab,
    required this.light,
    required this.selected,
    required this.wasSelected,
    required this.onTap,
  });

  final MainTab tab;
  final bool light;
  final bool selected;
  final bool wasSelected;
  final VoidCallback onTap;

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 460);
  static const _travel = 60.0;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _duration,
    value: widget.wasSelected ? 1 : 0,
  );
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    if (widget.wasSelected != widget.selected) _go();
  }

  @override
  void didUpdateWidget(_TabItem old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _go();
  }

  void _go() => widget.selected ? _c.forward() : _c.reverse();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.tab.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          height: 56,
          child: ClipRect(
            clipper: const _TabClipper(),
            child: AnimatedBuilder(
              animation: _t,
              builder: (context, _) {
                final t = _t.value;
                return Stack(
                  children: [
                    if (t < 1)
                      Positioned.fill(
                        top: -_travel * t,
                        bottom: _travel * t,
                        child: _TabFace(tab: widget.tab, on: false, light: widget.light),
                      ),
                    if (t > 0)
                      Positioned.fill(
                        top: _travel * (1 - t),
                        bottom: -_travel * (1 - t),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(color: widget.light ? Colors.white : AxisTabBar.darkBackground),
                            _TabFace(tab: widget.tab, on: true, light: widget.light),
                            Opacity(opacity: 1 - t, child: const _FlipShade()),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom Navigation/Item(130:9663) 한 면. 56 칸 위에서 12 아래에 23 아이콘(가운데), 42 아래에 12 라벨(줄 높이 140%, 가운데).
/// 라벨은 피그마처럼 칸 아래로 3 남짓 넘친다. 켜지면 검정 아이콘·SemiBold #181920(블랙모드는 흰 아이콘·흰 글씨),
/// 꺼지면 회색 아이콘·Regular #8B95A1(블랙모드 #494949).
class _TabFace extends StatelessWidget {
  const _TabFace({required this.tab, required this.on, required this.light});

  final MainTab tab;
  final bool on;
  final bool light;

  static const iconTop = 12.0;
  static const iconSize = 23.0;
  static const labelTop = 42.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: iconTop,
          left: 0,
          right: 0,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/tab/${tab._icon}${light ? '_light' : ''}_${on ? 'on' : 'off'}.svg',
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
        Positioned(
          top: labelTop,
          left: 0,
          right: 0,
          child: Text(
            tab.label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              letterSpacing: 0,
              fontWeight: on ? FontWeight.w600 : FontWeight.w400,
              color: light
                  ? (on ? const Color(0xFF181920) : const Color(0xFF8B95A1))
                  : (on ? Colors.white : const Color(0xFF494949)),
            ),
          ),
        ),
      ],
    );
  }
}

/// 칸(56) 아래로 넘치는 라벨이 잘리지 않게 아래만 [_overflow]만큼 더 보여 준다(굴러 들어오는 면은 60 아래라 안 보인다).
class _TabClipper extends CustomClipper<Rect> {
  const _TabClipper();

  static const _overflow = 4.0;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width, size.height + _overflow);

  @override
  bool shouldReclip(_TabClipper old) => false;
}

/// Flip Shade(위에서 아래로 #384A5E 30% → 0) + Fold Edge(윗변 1px, 가운데가 진한 #384A5E 18%).
class _FlipShade extends StatelessWidget {
  const _FlipShade();

  static const _ink = Color(0xFF384A5E);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _ink.withValues(alpha: 0.30),
                _ink.withValues(alpha: 0.16),
                _ink.withValues(alpha: 0.03),
                _ink.withValues(alpha: 0),
              ],
              stops: const [0, 0.18, 0.52, 1],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 1,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_ink.withValues(alpha: 0), _ink.withValues(alpha: 0.18), _ink.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
