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

/// 목록 ↔ 달성률 토글. 09 커뮤니티 상단 슬라이드([AxisCubeCarousel])와 같은 네모 큐브로 돈다: 0.5초,
/// cubic-bezier(0.34, 1.3, 0.64, 1), 원근 900, 옆으로 돌아간 면은 35%까지 어두워진다.
/// 상단 줄과 탭 바는 그대로 두고 그 사이 칸만 돈다. [forward]면 목록 → 달성률(오른쪽 면이 앞으로).
///
/// 면은 배경까지 포함한 화면 전체 사진이라 불투명하다(뒤가 비쳐 보이지 않는다). 누른 순간 지금 화면을 찍어 두고,
/// 새 화면은 한 번 그린 뒤 찍는다. 회전은 그 다음 프레임부터 시작하므로 새 화면을 만드는 시간이 회전 중간에 끼지 않는다.
Future<void> homeSwitchTo(BuildContext context, Widget screen, {required bool forward}) async {
  if (homeRotating.value) return;
  // 큐브 장면(웹에서는 사진으로 뜰 수 없는 HTML 요소)을 그림으로 바꿔 둔 한 프레임 뒤에 찍는다.
  homeRotating.value = true;
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) {
    homeRotating.value = false;
    return;
  }
  final from = _snapshot(context);
  if (from == null) homeRotating.value = false;
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

const homeRotateDuration = Duration(milliseconds: 500);

/// 목록 ↔ 달성률이 도는 중인지. 도는 동안 큐브 장면은 그림으로 대신 보인다.
final homeRotating = ValueNotifier<bool>(false);

/// 홈 화면에서 토글로 돌아가는 내용(배경 사진·상단 줄 제외). 도는 동안 제자리의 내용은 숨긴다.
class HomeRotateLayer extends StatelessWidget {
  const HomeRotateLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hidden = context.dependOnInheritedWidgetOfExactType<_HomeRotateScope>()?.hidden ?? false;
    return Visibility.maintain(visible: !hidden, child: child);
  }
}

class _HomeRotateScope extends InheritedWidget {
  const _HomeRotateScope({required this.hidden, required super.child});

  final bool hidden;

  @override
  bool updateShouldNotify(_HomeRotateScope old) => old.hidden != hidden;
}

/// [context] 화면 전체(배경 포함)를 담은 가장 가까운 그리기 경계를 이미지로 뜬다.
ui.Image? _snapshot(BuildContext context) {
  RenderObject? r = context.findRenderObject();
  while (r != null && r is! RenderRepaintBoundary) {
    r = r.parent;
  }
  if (r is! RenderRepaintBoundary || !r.hasSize) return null;
  return _capture(r, MediaQuery.devicePixelRatioOf(context));
}

ui.Image? _capture(RenderRepaintBoundary b, double dpr) {
  try {
    return b.toImageSync(pixelRatio: dpr);
  } catch (_) {
    return null;
  }
}

class _HomeRotate extends StatefulWidget {
  const _HomeRotate({required this.from, required this.forward, required this.child});

  /// 나가는 화면 전체 사진.
  final ui.Image from;
  final bool forward;

  /// 새 화면. 도는 동안에는 내용만 숨기고 배경·상단 줄·탭 바는 그대로 보인다.
  final Widget child;

  @override
  State<_HomeRotate> createState() => _HomeRotateState();
}

class _HomeRotateState extends State<_HomeRotate> with SingleTickerProviderStateMixin {
  // 09 커뮤니티 상단 슬라이드와 같은 값.
  static const _curve = Cubic(0.34, 1.3, 0.64, 1);
  static const _perspective = 900.0;
  static const _sideDim = 0.35;

  final _boundaryKey = GlobalKey();
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

  /// 새 화면이 한 번(내용까지) 그려진 뒤 사진을 뜨고, 제자리 내용은 숨긴 채 회전을 시작한다.
  void _start() {
    if (!mounted) return;
    final b = _boundaryKey.currentContext?.findRenderObject();
    if (b is RenderRepaintBoundary && b.hasSize) _to = _capture(b, MediaQuery.devicePixelRatioOf(context));
    if (_to == null) return _finish();
    setState(() {});
    _c.forward().whenComplete(_finish);
  }

  void _finish() {
    homeRotating.value = false;
    if (!mounted) return;
    setState(() {
      _from?.dispose();
      _to?.dispose();
      _from = _to = null;
    });
  }

  @override
  void dispose() {
    if (_from != null) homeRotating.value = false;
    _c.dispose();
    _from?.dispose();
    _to?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final from = _from;
    final to = _to;
    final child = _HomeRotateScope(
      // 첫 프레임은 새 내용을 사진으로 뜰 수 있게 그대로 그린다(나가는 면이 그 위를 덮는다).
      hidden: to != null,
      child: RepaintBoundary(
        key: _boundaryKey,
        child: IgnorePointer(ignoring: from != null, child: widget.child),
      ),
    );
    if (from == null) return child;
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.biggest;
        final mq = MediaQuery.of(context);
        final top = mq.padding.top + 50; // 상단 줄 아래
        final bottom = AxisTabBar.height + math.max(mq.viewPadding.bottom, AxisTabBar.homeIndicator);
        final content = Rect.fromLTRB(0, top, size.width, size.height - bottom);
        final dpr = mq.devicePixelRatio;
        final e = _curve.transform(_c.value);
        final dir = widget.forward ? 1.0 : -1.0;
        final outA = -dir * 90 * e;
        final inA = dir * 90 * (1 - e);
        // 등 돌린 면(|각| ≥ 90)은 그리지 않고, 먼 면부터 그린다.
        final faces = <(double, ui.Image)>[(outA, from), if (to != null) (inA, to)]
          ..removeWhere((f) => f.$1.abs() >= 90)
          ..sort((a, b) => b.$1.abs().compareTo(a.$1.abs()));
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            // 원근으로 커진 면이 상단 줄·탭 바를 덮지 않게 가운데 칸 안에서만 그린다.
            ClipRect(
              clipper: _RectClipper(content),
              child: Stack(
                fit: StackFit.expand,
                children: [for (final f in faces) _face(f.$2, dpr, f.$1, content, size)],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 화면 사진의 가운데(상단 줄과 탭 바 사이)만 잘라 큐브 옆면으로 돌린다.
  Widget _face(ui.Image image, double dpr, double angle, Rect content, Size size) {
    final d = size.width / 2; // 큐브 반지름
    final dim = _sideDim * math.min(1, angle.abs() / 30);
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
              Positioned(
                left: 0,
                top: 0,
                child: RawImage(image: image, scale: dpr),
              ),
              Positioned.fromRect(
                rect: content,
                child: ColoredBox(color: Colors.black.withValues(alpha: dim)),
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

/// 상단 줄(상태바 바로 아래 높이 50, 피그마 Header 48h50): 왼쪽 axis 로고, 가운데 "목록 | 달성률" 알약 토글, (있으면) 오른쪽 + 버튼.
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
      height: 50,
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
