import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';
import 'kit_buttons.dart';

/// Nav/Back Title(130:9961) · Nav/Title(130:9407): 뒤로가기 + 가운데 제목(18 Bold gray06)
/// + 오른쪽 행동 아이콘들(예: AxisIconButton(icon: KitIcon.navPlus)). 상태바 바로 아래 붙는 높이 50.
class AxisBackTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const AxisBackTitleBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
    this.showBack = true,
    this.backgroundColor,
  });

  final String title;

  /// 없으면 Navigator.maybePop.
  final VoidCallback? onBack;

  /// 오른쪽에 붙는 44px 아이콘 버튼들.
  final List<Widget> actions;
  final bool showBack;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 44.0 * (actions.length > 1 ? actions.length : 1) + 8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AxisText.navTitle,
            ),
          ),
          if (showBack) Positioned(left: 0, child: AxisIconButton.back(onPressed: onBack)),
          if (actions.isNotEmpty)
            Positioned(
              right: 0,
              child: Row(mainAxisSize: MainAxisSize.min, children: actions),
            ),
        ],
      ),
    );
  }
}

/// Nav/Back Share(130:10085): 흰 원형 뒤로가기(그림자) + 가운데 제목 + 공유(그리고 선택적으로 북마크). 상태바 바로 아래 높이 50.
class AxisBackShareBar extends StatelessWidget implements PreferredSizeWidget {
  const AxisBackShareBar({super.key, required this.title, this.onBack, this.onShare, this.trailing = const []});

  final String title;
  final VoidCallback? onBack;

  /// null이면 공유 버튼을 숨긴다.
  final VoidCallback? onShare;

  /// 공유 앞에 더 붙일 버튼(예: 북마크 AxisIconButton).
  final List<Widget> trailing;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    final right = [
      ...trailing,
      if (onShare != null) AxisIconButton(icon: KitIcon.navShare, tooltip: '공유', onPressed: onShare),
    ];
    return Container(
      color: Colors.white,
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 44.0 * (right.length > 1 ? right.length : 1) + 8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AxisText.navTitle,
            ),
          ),
          Positioned(left: 0, child: AxisIconButton.back(onPressed: onBack, floating: true)),
          if (right.isNotEmpty)
            Positioned(
              right: 0,
              child: Row(mainAxisSize: MainAxisSize.min, children: right),
            ),
        ],
      ),
    );
  }
}

/// Nav/Greeting(130:9412): 연파랑 그라디언트 띠에 "이름 님" + 파란 응원 문구.
class AxisGreetingBanner extends StatelessWidget {
  const AxisGreetingBanner({super.key, required this.name, required this.message});

  /// 예: "수현 님"
  final String name;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 37),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.blue01, Color(0xFFEFF8FF)]),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.gray09),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.brand),
            ),
          ),
        ],
      ),
    );
  }
}

/// 고정된 상단 줄 바로 아래에 까는 그라데이션. 스크롤된 내용이 줄 밑에서 딱 잘리지 않고
/// 줄 색([color])으로 서서히 묻힌다(인스타처럼). 맨 위에 있을 때는 내용을 덮지 않게 숨긴다.
class ScrollTopFade extends StatefulWidget {
  const ScrollTopFade({super.key, required this.color, required this.child, this.height = 24});

  final Color color;
  final Widget child;
  final double height;

  @override
  State<ScrollTopFade> createState() => _ScrollTopFadeState();
}

class _ScrollTopFadeState extends State<ScrollTopFade> {
  double _amount = 0;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final v = (n.metrics.pixels / widget.height).clamp(0.0, 1.0);
    if (v != _amount) setState(() => _amount = v);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: NotificationListener<ScrollNotification>(onNotification: _onScroll, child: widget.child),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: widget.height,
          child: IgnorePointer(
            child: Opacity(
              opacity: _amount,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [widget.color, widget.color.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 상단 줄 아래 내용 칸([Expanded])에 [ScrollTopFade]를 씌운 것.
class FadeExpanded extends Expanded {
  FadeExpanded({super.key, required Color fadeColor, required Widget child})
    : super(
        child: ScrollTopFade(color: fadeColor, child: child),
      );
}
