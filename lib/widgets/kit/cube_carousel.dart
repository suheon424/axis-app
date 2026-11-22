import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 큐브 한 층을 돌리듯 넘어가는 캐러셀(시안 "09 커뮤니티 · 한 층 돌리기").
/// 네 옆면을 가진 기둥의 각 면에 [faceBuilder]의 면을 차례로 붙이고(면이 4개보다 적으면 되풀이),
/// 한 칸 넘길 때마다 기둥이 90° 돈다: 0.5초, 살짝 튀는 감속(cubic-bezier(0.34, 1.3, 0.64, 1)),
/// 원근 900, 앞면이 아닌 면은 검정 35%로 어둡게, 뒷면은 그리지 않는다.
/// 좌우로 30 넘게 밀면 넘어가고, [autoplay]면 3.5초마다 저절로 돈다.
class AxisCubeCarousel extends StatefulWidget {
  const AxisCubeCarousel({
    super.key,
    required this.faceCount,
    required this.faceBuilder,
    required this.size,
    this.controller,
    this.onChanged,
    this.autoplay = true,
  });

  /// 면 수. 4보다 적으면 기둥의 네 옆면에 되풀이해 붙인다.
  final int faceCount;

  /// [index]번 면을 그린다. [dim](0~0.35)은 옆으로 돌아간 만큼 어둡게 덮을 검정의 불투명도로,
  /// 시안처럼 카드마다 덮는다(카드 사이 틈은 어둡히지 않는다).
  final Widget Function(BuildContext context, int index, double dim) faceBuilder;

  /// 한 면의 크기(시안 350×150).
  final Size size;
  final AxisCubeCarouselController? controller;

  /// 앞에 온 면 번호(0부터).
  final ValueChanged<int>? onChanged;
  final bool autoplay;

  /// 테스트에서 끝없는 자동 회전을 끈다.
  @visibleForTesting
  static bool autoplayEnabled = true;

  static const duration = Duration(milliseconds: 500);
  static const interval = Duration(milliseconds: 3500);
  static const curve = Cubic(0.34, 1.3, 0.64, 1);
  static const perspective = 900.0;
  static const sideDim = 0.35;

  @override
  State<AxisCubeCarousel> createState() => _AxisCubeCarouselState();
}

/// 바깥(이전·다음 버튼)에서 넘길 때 쓴다.
class AxisCubeCarouselController {
  _AxisCubeCarouselState? _state;

  void next() => _state?._step(1);
  void previous() => _state?._step(-1);
}

class _AxisCubeCarouselState extends State<AxisCubeCarousel> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: AxisCubeCarousel.duration);
  double _from = 0, _to = 0;
  int _index = 0; // 끝없이 늘어나는 칸 번호
  Timer? _timer;
  double _dragDx = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _anim.addListener(() => setState(() {}));
    _restartTimer();
  }

  @override
  void didUpdateWidget(AxisCubeCarousel old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._state = null;
      widget.controller?._state = this;
    }
    if (old.autoplay != widget.autoplay) _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller?._state == this) widget.controller?._state = null;
    _anim.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (!widget.autoplay || !AxisCubeCarousel.autoplayEnabled) return;
    _timer = Timer.periodic(AxisCubeCarousel.interval, (_) => _step(1, fromTimer: true));
  }

  double get _pos => _from + (_to - _from) * AxisCubeCarousel.curve.transform(_anim.value);

  void _step(int d, {bool fromTimer = false}) {
    if (widget.faceCount == 0) return;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    setState(() {
      _from = _pos;
      _index += d;
      _to = _index.toDouble();
    });
    if (reduce) {
      _anim.value = 1;
    } else {
      _anim.forward(from: 0);
    }
    if (!fromTimer) _restartTimer();
    final n = widget.faceCount;
    widget.onChanged?.call(((_index % n) + n) % n);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.size.width, h = widget.size.height;
    final d = w / 2; // 기둥 반지름(면 너비의 절반)
    final pos = _pos;
    final n = widget.faceCount;
    // 앞면 근처 두 칸(왼쪽·오른쪽 옆면)까지만 그리면 된다. 뒤쪽은 먼저, 앞쪽은 나중에.
    final base = pos.floor();
    final slots = <(int, double)>[];
    for (var k = base - 1; k <= base + 2; k++) {
      final a = (k - pos) * 90; // 이 칸이 정면에서 돌아간 각도
      if (a.abs() >= 90) continue; // 뒷면·옆으로 완전히 누운 면
      slots.add((k, a));
    }
    slots.sort((x, y) => y.$2.abs().compareTo(x.$2.abs()));
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _dragDx = 0,
      onHorizontalDragUpdate: (e) => _dragDx += e.delta.dx,
      onHorizontalDragEnd: (_) {
        if (_dragDx < -30) _step(1);
        if (_dragDx > 30) _step(-1);
      },
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final (k, a) in slots)
              Positioned.fill(
                child: Transform(
                  alignment: Alignment.center,
                  // CSS: perspective 900 · translateZ(-d) · rotateY(a) · translateZ(d). 플러터는 z가 화면 안쪽이 +.
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 1 / AxisCubeCarousel.perspective)
                    ..translateByDouble(0, 0, d, 1)
                    ..rotateY(-a * math.pi / 180)
                    ..translateByDouble(0, 0, -d, 1),
                  child: IgnorePointer(
                    ignoring: a.abs() > 1,
                    child: widget.faceBuilder(
                      context,
                      ((k % n) + n) % n,
                      AxisCubeCarousel.sideDim * math.min(1, a.abs() / 30).toDouble(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
