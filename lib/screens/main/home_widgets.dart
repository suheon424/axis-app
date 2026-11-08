import 'dart:math' as math;
import 'dart:ui' as ui show Image;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

/// 목록 ↔ 달성률 토글(시안 "③ 목록 ↔ 달성률 · 회전"). 위 상단 줄과 아래 탭 바는 그대로 두고,
/// 그 사이 화면만 큐브의 두 옆면처럼 90° 돈다: 0.6초, cubic-bezier(0.65, 0, 0.35, 1), 원근 1100,
/// 돌아가는 동안 앞이 아닌 면은 검정 55%까지 어두워진다. [forward]면 목록 → 달성률(오른쪽 면이 앞으로).
///
/// 끊기지 않게 두 화면을 사진으로 떠서 돌린다: 누른 순간 지금 화면을 찍어 두고, 새 화면은 한 번 그린 뒤
/// 찍는다. 회전은 그 다음 프레임부터 시작하므로 새 화면을 만드는 시간이 회전 중간에 끼지 않는다.
void homeSwitchTo(BuildContext context, Widget screen, {required bool forward}) {
  final from = _snapshot(context);
  Navigator.of(context).pushReplacement(
    PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => screen,
      // 길 넘김 자체는 바로 끝내 이전 화면을 더 그리지 않는다. 회전은 [_HomeRotate]가 따로 돌린다.
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, _, _, child) =>
          from == null ? child : _HomeRotate(from: from, forward: forward, child: child),
    ),
  );
}

const homeRotateDuration = Duration(milliseconds: 600);

/// [context]가 들어 있는 화면 전체를 이미지로 뜬다(화면 전체를 감싼 RepaintBoundary).
ui.Image? _snapshot(BuildContext context) {
  final screen = context.findRenderObject();
  var node = screen?.parent;
  while (node != null && node is! RenderRepaintBoundary) {
    node = node.parent;
  }
  if (node is! RenderRepaintBoundary || !node.hasSize) return null;
  try {
    return node.toImageSync(pixelRatio: MediaQuery.devicePixelRatioOf(context));
  } catch (_) {
    return null;
  }
}

class _HomeRotate extends StatefulWidget {
  const _HomeRotate({required this.from, required this.forward, required this.child});

  /// 나가는 화면 사진.
  final ui.Image from;
  final bool forward;

  /// 새 화면. 도는 동안에는 상단 줄·탭 바만 보이고, 끝나면 전체가 보인다.
  final Widget child;

  @override
  State<_HomeRotate> createState() => _HomeRotateState();
}

class _HomeRotateState extends State<_HomeRotate> with SingleTickerProviderStateMixin {
  static const _curve = Cubic(0.65, 0, 0.35, 1);
  static const _perspective = 1100.0;
  static const _dim = 0.55;

  final _childKey = GlobalKey();
  late final _c = AnimationController(vsync: this, duration: homeRotateDuration)..addListener(_tick);
  ui.Image? _from;
  ui.Image? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.from;
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _tick() => setState(() {});

  /// 새 화면이 한 번 그려진 뒤 사진을 뜨고 회전을 시작한다.
  void _start() {
    if (!mounted) return;
    final boundary = _childKey.currentContext?.findRenderObject();
    if (boundary is RenderRepaintBoundary) {
      try {
        _to = boundary.toImageSync(pixelRatio: MediaQuery.devicePixelRatioOf(context));
      } catch (_) {}
    }
    if (_to == null) return _finish();
    _c.forward().whenComplete(_finish);
  }

  void _finish() {
    if (!mounted) return;
    setState(() {
      _from?.dispose();
      _to?.dispose();
      _from = _to = null;
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _from?.dispose();
    _to?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final from = _from;
    final to = _to;
    final child = RepaintBoundary(
      key: _childKey,
      child: IgnorePointer(ignoring: from != null, child: widget.child),
    );
    if (from == null) return child;
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.biggest;
        // 사진을 뜨기 전 첫 프레임: 새 화면을 그리는 동안 이전 화면 사진으로 덮어 둔다.
        if (to == null) {
          return Stack(
            fit: StackFit.expand,
            children: [
              child,
              RawImage(image: from, fit: BoxFit.fill),
            ],
          );
        }
        final mq = MediaQuery.of(context);
        final top = mq.padding.top + 58; // 상단 줄 아래
        final bottom = AxisTabBar.height + math.max(mq.viewPadding.bottom, AxisTabBar.homeIndicator);
        final content = Rect.fromLTRB(0, top, size.width, size.height - bottom);
        final e = _curve.transform(_c.value);
        final dir = widget.forward ? 1.0 : -1.0;
        final outA = -dir * 90 * e;
        final inA = dir * 90 * (1 - e);
        final outFace = _face(from, outA, content, size);
        final inFace = _face(to, inA, content, size);
        return Stack(
          fit: StackFit.expand,
          children: [
            child, // 상단 줄·탭 바(가운데는 아래에서 덮는다)
            // 원근으로 커진 면이 상단 줄·탭 바를 덮지 않게 가운데 칸 안에서만 그린다.
            ClipRect(
              clipper: _RectClipper(content),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fromRect(
                    rect: content,
                    child: const ColoredBox(color: Colors.black),
                  ),
                  if (outA.abs() > inA.abs()) ...[outFace, inFace] else ...[inFace, outFace],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 사진의 가운데(상단 줄과 탭 바 사이)만 잘라 큐브 옆면으로 돌린다.
  Widget _face(ui.Image image, double angle, Rect content, Size size) {
    final d = size.width / 2; // 큐브 반지름
    return Positioned.fill(
      child: Transform(
        origin: content.center,
        // CSS: perspective · translateZ(-d) · rotateY(a) · translateZ(d). 플러터는 z가 화면 안쪽이 +.
        transform: Matrix4.identity()
          ..setEntry(3, 2, 1 / _perspective)
          ..translateByDouble(0, 0, d, 1)
          ..rotateY(-angle * math.pi / 180)
          ..translateByDouble(0, 0, -d, 1),
        child: ClipRect(
          clipper: _RectClipper(content),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RawImage(image: image, fit: BoxFit.fill),
              Positioned.fromRect(
                rect: content,
                child: ColoredBox(color: Colors.black.withValues(alpha: _dim * angle.abs() / 90)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RectClipper extends CustomClipper<Rect> {
  const _RectClipper(this.rect);

  final Rect rect;

  @override
  Rect getClip(Size size) => rect;

  @override
  bool shouldReclip(_RectClipper old) => old.rect != rect;
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
