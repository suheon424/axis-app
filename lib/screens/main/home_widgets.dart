import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';

/// 07_01 홈 화면들(목록·달성률)이 함께 쓰는 조각: 배경 사진, 상단 줄, 어두운 카드, 카테고리 줄, 로딩·오류 카드.

/// 07 배경 사진(image 37). 검정 위에 낮은 불투명도로 깐다.
const homeBgPhoto = 'assets/images/main/home_bg_photo.jpg';

/// 홈 카드 바탕(#010104 75%, 뒤 흐림 5).
const homeCardColor = Color(0xBF010104);

/// 어두운 카드 안 구분선(흰 8%).
const homeDividerColor = Color(0x14FFFFFF);

/// 어두운 카드 안 막대·로딩 막대의 바탕(흰 12%).
const homeTrackColor = Color(0x1FFFFFFF);

/// 화면을 밀어 넣는 애니메이션 없이 바로 바꾼다(목록 ↔ 달성률 토글).
void homeSwitchTo(BuildContext context, Widget screen) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => screen,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

/// 배경 사진 두 장: 20% 한 장 + 50% 한 장(위 회색 → 아래 파랑으로 물든). [top]은 상태 표시줄 높이.
class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key, required this.top, this.blueTint = true});

  final double top;

  /// 목록 화면처럼 아래쪽을 파랗게 물들일지.
  final bool blueTint;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: top - 48,
          left: -1,
          right: -1,
          height: 849,
          child: const Opacity(
            opacity: 0.2,
            child: Image(image: AssetImage(homeBgPhoto), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: top + 47,
          left: 0,
          right: -2,
          height: 849,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Opacity(
                opacity: 0.5,
                child: Image(image: AssetImage(homeBgPhoto), fit: BoxFit.cover),
              ),
              if (blueTint)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33858C94), Color(0x33004FED)],
                      stops: [0, 0.78],
                    ),
                  ),
                ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33858C94), Color(0x00666666)],
                    stops: [0, 0.37],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 상단 줄(높이 48): 왼쪽 axis 로고, 가운데 "목록 | 달성률" 알약 토글, (있으면) 오른쪽 + 버튼.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, required this.achievement, required this.onToggle, this.onAdd, this.onLogoLongPress});

  /// true면 "달성률"이 선택된 상태.
  final bool achievement;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onAdd;

  /// 데모용: 로고를 길게 누르면 화면 상태(로딩·오류·알림 권한)를 골라 볼 수 있다.
  final VoidCallback? onLogoLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            child: GestureDetector(
              onLongPress: onLogoLongPress,
              child: SvgPicture.asset(
                'assets/icons/wordmark_axis.svg',
                width: 52,
                height: 18.4,
                semanticsLabel: 'axis',
              ),
            ),
          ),
          AxisPillSegment(
            labels: const ['목록', '달성률'],
            selected: achievement ? 1 : 0,
            onChanged: (i) {
              if ((i == 1) != achievement) onToggle(i == 1);
            },
          ),
          if (onAdd != null)
            Positioned(
              right: 4,
              child: IconButton(
                tooltip: '일정 추가',
                onPressed: onAdd,
                icon: const AxisIcon(KitIcon.navPlus, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// 어두운 반투명 카드(굴곡 8, 뒤 흐림 5).
class HomeDarkCard extends StatelessWidget {
  const HomeDarkCard({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 18)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(width: double.infinity, color: homeCardColor, padding: padding, child: child),
      ),
    );
  }
}

/// List/Category Row(130:10034)의 어두운 카드 판: 색 네모, 이름·"30일 중 n일 실천", 미니 바, %, ›.
class HomeCategoryRow extends StatelessWidget {
  const HomeCategoryRow({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.onTap,
    this.divider = true,
  });

  final Color color;
  final String title;
  final String subtitle;

  /// 0~100
  final int percent;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: '$title, $subtitle, $percent%',
      onTap: onTap,
      scale: 1,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: pressed ? const Color(0x0DFFFFFF) : null,
          border: divider ? const Border(bottom: BorderSide(color: homeDividerColor)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AxisText.rowTitle.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AxisText.caption.copyWith(color: AppColors.gray05)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _MiniBar(value: percent / 100, color: color),
            const SizedBox(width: 12),
            SizedBox(
              width: 44,
              child: Text(
                '$percent%',
                textAlign: TextAlign.right,
                style: AxisText.rowTitle.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const AxisChevronRight(size: 18, color: AppColors.gray05),
          ],
        ),
      ),
    );
  }
}

/// 어두운 바탕용 미니 바(64×4, 바탕 흰 12%, 모서리 각짐).
class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 4,
      alignment: Alignment.centerLeft,
      color: homeTrackColor,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        heightFactor: 1,
        child: ColoredBox(color: color),
      ),
    );
  }
}

/// 어두운 바탕용 로딩 막대(흰 12%, 굴곡 4). 천천히 깜빡인다.
class HomeSkeletonBar extends StatefulWidget {
  const HomeSkeletonBar({super.key, this.width, this.height = 14, this.radius = 4});

  final double? width;
  final double height;
  final double radius;

  @override
  State<HomeSkeletonBar> createState() => _HomeSkeletonBarState();
}

class _HomeSkeletonBarState extends State<HomeSkeletonBar> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.5).animate(_c),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: homeTrackColor, borderRadius: BorderRadius.circular(widget.radius)),
      ),
    );
  }
}

/// 07_01 홈_목록 · 네트워크 오류의 카드: 느낌표 원, 안내 문구, "다시 시도".
class HomeErrorCard extends StatelessWidget {
  const HomeErrorCard({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF181C23), Color(0xFF12161C)],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0x14FFFFFF), shape: BoxShape.circle),
              child: const AxisIcon(KitIcon.stateAlert, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              '인터넷 연결이 불안정해요',
              textAlign: TextAlign.center,
              style: AxisText.rowTitle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '연결 상태를 확인한 뒤\n다시 시도해 주세요.',
              textAlign: TextAlign.center,
              style: AxisText.body.copyWith(color: const Color(0x99FFFFFF)),
            ),
            const SizedBox(height: 16),
            AxisSmallButton(label: '다시 시도', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
