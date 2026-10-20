import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';

/// 큐브 한 면의 3×3 칸 색. 위 줄부터 왼쪽→오른쪽 순서.
typedef CubeFace = List<Color>;

/// 07_02 피그마 큐브 그림의 칸 색(앞·위·오른쪽). 보이지 않는 면은 회색.
class CubeFaces {
  const CubeFaces({
    required this.front,
    required this.top,
    required this.right,
    this.back = _gray9,
    this.left = _gray9,
    this.bottom = _gray9,
  });

  final CubeFace front, top, right, back, left, bottom;

  static const _gray9 = <Color>[
    CubeColors.gray, CubeColors.gray, CubeColors.gray, //
    CubeColors.gray, CubeColors.gray, CubeColors.gray,
    CubeColors.gray, CubeColors.gray, CubeColors.gray,
  ];

  static const figma = CubeFaces(
    front: [
      CubeColors.blue, CubeColors.yellow, CubeColors.red, //
      CubeColors.blue, CubeColors.yellow, CubeColors.red,
      CubeColors.blue, CubeColors.yellow, CubeColors.red,
    ],
    top: [
      CubeColors.orange, CubeColors.blue, CubeColors.yellow, //
      CubeColors.orange, CubeColors.blue, CubeColors.yellow,
      CubeColors.orange, CubeColors.blue, CubeColors.yellow,
    ],
    right: _gray9,
  );
}

/// 07_02 달성률의 3D 큐브. Spline 없이 앱이 직접 그린다.
///
/// - 끌면 큐브가 따라 돌고, 놓으면 관성으로 조금 더 돌다가 피그마 그림 각도로 돌아온다.
/// - 큐브 위의 손가락(스와이프) 버튼은 누르고 있는 동안 사라졌다가 손을 떼면 다시 나타난다.
class RubiksCube extends StatefulWidget {
  const RubiksCube({
    super.key,
    this.faces = CubeFaces.figma,
    this.cubeOffset = const Offset(7, -15),
    this.fingerOffset = const Offset(0, 9.5),
  });

  final CubeFaces faces;

  /// 큐브와 손가락 버튼이 가운데에서 벗어난 정도(피그마 위치 기준).
  /// 기울어진 큐브는 그림 중심이 (-7, 7)쯤 치우쳐 그려져서 그만큼 되돌린다.
  final Offset cubeOffset;
  final Offset fingerOffset;

  static const fingerKey = Key('home_cube_finger');
  static const cubeKey = Key('home_cube');

  /// 피그마 그림의 각도(라디안). 오른쪽 면과 윗면이 조금 보인다.
  static const restYaw = -0.27;
  static const restPitch = 0.36;

  @override
  State<RubiksCube> createState() => _RubiksCubeState();
}

class _RubiksCubeState extends State<RubiksCube> with SingleTickerProviderStateMixin {
  double _yaw = RubiksCube.restYaw;
  double _pitch = RubiksCube.restPitch;
  Offset _velocity = Offset.zero; // 라디안/초
  bool _pressed = false;
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  static const _radPerPx = 0.012;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration now) {
    final dt = _last == Duration.zero ? 1 / 60 : (now - _last).inMicroseconds / 1e6;
    _last = now;
    setState(() {
      // 관성: 속도를 줄이며 더 돌린다.
      _yaw += _velocity.dx * dt;
      _pitch = (_pitch + _velocity.dy * dt).clamp(-1.4, 1.4);
      _velocity *= math.pow(0.04, dt).toDouble();
      // 원래 각도로 끌어당긴다(돌아온 바퀴 수는 버린다).
      final k = 1 - math.pow(0.02, dt).toDouble();
      final dyaw = _wrap(RubiksCube.restYaw - _yaw);
      _yaw += dyaw * k * (_velocity.distance < 1 ? 1 : 0.15);
      _pitch += (RubiksCube.restPitch - _pitch) * k * (_velocity.distance < 1 ? 1 : 0.15);
    });
    final settled =
        _velocity.distance < 0.01 &&
        _wrap(RubiksCube.restYaw - _yaw).abs() < 0.001 &&
        (RubiksCube.restPitch - _pitch).abs() < 0.001;
    if (settled) {
      _ticker.stop();
      _last = Duration.zero;
    }
  }

  static double _wrap(double a) {
    a = (a + math.pi) % (2 * math.pi);
    if (a < 0) a += 2 * math.pi;
    return a - math.pi;
  }

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  void _onPanStart(DragStartDetails _) {
    _ticker.stop();
    _last = Duration.zero;
    _velocity = Offset.zero;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _yaw += d.delta.dx * _radPerPx;
      _pitch = (_pitch + d.delta.dy * _radPerPx).clamp(-1.4, 1.4);
    });
  }

  void _onPanEnd(DragEndDetails d) {
    _velocity = d.velocity.pixelsPerSecond * _radPerPx;
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onPanCancel: () => _onPanEnd(DragEndDetails()),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Transform.translate(
                offset: widget.cubeOffset,
                child: CustomPaint(
                  key: RubiksCube.cubeKey,
                  size: const Size(260, 260),
                  painter: _CubePainter(faces: widget.faces, yaw: _yaw, pitch: _pitch),
                ),
              ),
            ),
            Center(
              child: Transform.translate(
                offset: widget.fingerOffset,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    key: RubiksCube.fingerKey,
                    opacity: _pressed ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: const _FingerButton(),
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

class _V {
  const _V(this.x, this.y, this.z);
  final double x, y, z;
  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator *(double s) => _V(x * s, y * s, z * s);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
}

/// 면 하나: 바깥 방향 [n], 칸의 가로 방향 [u](왼→오), 세로 방향 [v](위→아래). 오른손 좌표, y가 위.
class _FaceDef {
  const _FaceDef(this.n, this.u, this.v);
  final _V n, u, v;
}

const _front = _FaceDef(_V(0, 0, 1), _V(1, 0, 0), _V(0, -1, 0));
const _back = _FaceDef(_V(0, 0, -1), _V(-1, 0, 0), _V(0, -1, 0));
const _right = _FaceDef(_V(1, 0, 0), _V(0, 0, -1), _V(0, -1, 0));
const _left = _FaceDef(_V(-1, 0, 0), _V(0, 0, 1), _V(0, -1, 0));
const _top = _FaceDef(_V(0, 1, 0), _V(1, 0, 0), _V(0, 0, 1));
const _bottom = _FaceDef(_V(0, -1, 0), _V(1, 0, 0), _V(0, 0, -1));

class _CubePainter extends CustomPainter {
  _CubePainter({required this.faces, required this.yaw, required this.pitch});

  final CubeFaces faces;
  final double yaw, pitch;

  /// 큐브 한 변(3칸)의 절반, 화면 픽셀. 기본 각도에서 피그마 그림(177×186)과 같은 크기가 된다.
  static const _half = 66.0;
  static const _camera = 9.0; // 큐브 반변의 몇 배 거리에서 보는지(원근감)
  static const _light = _V(-0.35, 0.6, 0.72);
  static const _halfway = _V(-0.19, 0.33, 0.92); // 빛과 시선(0,0,1)의 중간 방향

  _V _rotate(_V p) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final x1 = p.x * cy + p.z * sy;
    final z1 = -p.x * sy + p.z * cy;
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final y2 = p.y * cp - z1 * sp;
    final z2 = p.y * sp + z1 * cp;
    return _V(x1, y2, z2);
  }

  Offset _project(_V p, Offset c) {
    final s = _camera / (_camera - p.z);
    return c + Offset(p.x * s * _half, -p.y * s * _half);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final defs = [
      (_front, faces.front),
      (_back, faces.back),
      (_right, faces.right),
      (_left, faces.left),
      (_top, faces.top),
      (_bottom, faces.bottom),
    ];
    for (final (def, colors) in defs) {
      final n = _rotate(def.n);
      if (n.z <= 0.001) continue; // 볼록한 큐브라 앞을 향한 면끼리는 겹치지 않는다.
      final diffuse = 0.7 + 0.3 * math.max(0.0, n.dot(_light));
      final spec = math.pow(math.max(0.0, n.dot(_halfway)), 6).toDouble();

      // 메탈릭: 면 대각선을 따라 반사광 띠를 두고, 면의 방향에 따라 띠가 미끄러지게 한다.
      // 큐브를 돌리면 빛 반사가 면 위를 지나간다.
      final a = _project(_rotate(def.n + def.u * -1 + def.v * -1), c);
      final b = _project(_rotate(def.n + def.u + def.v), c);
      final t = 0.5 + 1.1 * (n.x * 0.75 - n.y * 0.55);
      final mid = Offset.lerp(a, b, t)!;
      final half = (b - a) * 0.5;
      Shader sheen(List<Color> colors) => LinearGradient(
        colors: colors,
        stops: const [0, 0.38, 0.5, 0.62, 1],
      ).createShader(Rect.fromPoints(mid - half, mid + half));
      Paint metal(Color base, double gloss) => Paint()
        ..shader = sheen([
          Color.lerp(Colors.black, base, diffuse * 0.42)!,
          Color.lerp(Colors.black, base, diffuse * 0.95)!,
          Color.lerp(Color.lerp(Colors.black, base, diffuse)!, Colors.white, gloss * (0.4 + 0.45 * spec))!,
          Color.lerp(Colors.black, base, diffuse * 0.95)!,
          Color.lerp(Colors.black, base, diffuse * 0.42)!,
        ]);

      // 면 바탕(검정 몸통). 좌표는 큐브 반변을 1로 둔다.
      canvas.drawPath(_roundedQuad(def, 0, 0, 2, 2, 0.08, c), metal(const Color(0xFF3A3A40), 0.5));

      for (var i = 0; i < 9; i++) {
        final row = i ~/ 3, col = i % 3;
        const cell = 2 / 3, inset = 0.055;
        final x = col * cell + inset, y = row * cell + inset, w = cell - 2 * inset;
        canvas.drawPath(_roundedQuad(def, x, y, w, w, 0.07, c), metal(colors[i], 1));
        // 칸 가장자리의 얇은 반사(모서리 깎인 면).
        canvas.drawPath(
          _roundedQuad(def, x, y, w, w, 0.07, c),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = Colors.white.withValues(alpha: 0.12 + 0.25 * spec),
        );
        // 윗부분에 살짝 광택.
        final gloss = _roundedQuad(def, x + inset * 0.8, y + inset * 0.8, w - 1.6 * inset, w * 0.4, 0.05, c);
        canvas.drawPath(gloss, Paint()..color = Colors.white.withValues(alpha: 0.06 + 0.1 * spec));
      }
    }
  }

  /// 면 위 (a,b)에서 w×h 크기, 모서리 반지름 r인 둥근 사각형. a·b는 면의 왼쪽 위(0..2) 기준.
  Path _roundedQuad(_FaceDef d, double a, double b, double w, double h, double r, Offset c) {
    _V at(double s, double t) => d.n + d.u * (s - 1) + d.v * (t - 1);
    final pts = <Offset>[];
    const steps = 4;
    final corners = [
      (a + w - r, b + r, -math.pi / 2), // 오른쪽 위
      (a + w - r, b + h - r, 0.0), // 오른쪽 아래
      (a + r, b + h - r, math.pi / 2), // 왼쪽 아래
      (a + r, b + r, math.pi), // 왼쪽 위
    ];
    for (final (cs, ct, start) in corners) {
      for (var k = 0; k <= steps; k++) {
        final ang = start + (math.pi / 2) * k / steps;
        pts.add(_project(_rotate(at(cs + r * math.cos(ang), ct + r * math.sin(ang))), c));
      }
    }
    return Path()..addPolygon(pts, true);
  }

  @override
  bool shouldRepaint(_CubePainter old) => old.yaw != yaw || old.pitch != pitch || old.faces != faces;
}

/// 60 원형(검정 60% + 흐림) 안의 스와이프 손가락 아이콘.
class _FingerButton extends StatelessWidget {
  const _FingerButton();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          color: const Color(0x99000000),
          child: SvgPicture.asset('assets/icons/home_ic_swipe.svg', width: 28, height: 28),
        ),
      ),
    );
  }
}
