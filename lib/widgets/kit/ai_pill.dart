import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import 'kit_buttons.dart';

/// 화면 아래 떠 있는 AI 알약 버튼(07_05·07_06·07_07 "틀어진 일정 맞추기", 07_09 "동선 최적화하기").
///
/// 시안(07_07 J모드 · 제안 펼침_이동/삭제 Frame 278): 흰 알약 + 바깥쪽 1px 선(왼쪽 #A3C1F5 → 오른쪽 #1C67EF),
/// 뒤에 파란 각도 그라디언트 선(1.4)을 가진 조금 큰 알약을 흐림 8로 번지게 깐다.
/// 왼쪽 아이콘은 두 버튼 모두 같은 AI 동그라미([AxisAiPlusOrb]).
/// 선·번짐·아이콘 원의 그라디언트는 [spinDuration]마다 함께 360° 돈다(0801 입력창과 같은 빠르기).
class AxisAiPill extends StatefulWidget {
  const AxisAiPill({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  static const spinDuration = Duration(milliseconds: 3200);

  /// 테스트에서 끝없는 회전 때문에 pumpAndSettle이 멈추지 않게 끌 수 있다.
  @visibleForTesting
  static bool spinEnabled = true;

  @override
  State<AxisAiPill> createState() => _AxisAiPillState();
}

class _AxisAiPillState extends State<AxisAiPill> with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(vsync: this, duration: AxisAiPill.spinDuration);

  @override
  void initState() {
    super.initState();
    if (AxisAiPill.spinEnabled) _spin.repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: widget.label,
      onTap: widget.onTap,
      scale: 0.95,
      builder: (context, pressed) => CustomPaint(
        painter: _AiPillPainter(_spin, pressed: pressed),
        child: Container(
          constraints: const BoxConstraints(minHeight: 37),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AxisAiPlusOrb(turns: _spin),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  letterSpacing: -0.32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiPillPainter extends CustomPainter {
  _AiPillPainter(this.turns, {required this.pressed}) : super(repaint: turns);

  final Animation<double> turns;
  final bool pressed;

  static const _light = Color(0xFFA3C1F5);
  static const _blue = Color(0xFF1C67EF);

  // 번짐 알약의 각도 그라디언트(Frame 54 선).
  static const _glowColors = [
    Color(0xFF004CCE),
    Color(0xFF005BF1),
    Color(0xFF136BFF),
    Color(0xFF005FFF),
    Color(0xFF003DAB),
    Color(0xFF004CCE),
  ];
  static const _glowStops = [0.0, 0.145, 0.335, 0.879, 0.972, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final rotation = GradientRotation(turns.value * 2 * math.pi);

    // 뒤 번짐: 가로 4, 세로 1 큰 알약을 흰 채우기 + 파란 선으로 그린 뒤 통째로 흐린다.
    final glow = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center + const Offset(0, 0.5), width: size.width + 4, height: size.height + 1),
      const Radius.circular(100),
    );
    canvas.saveLayer(rect.inflate(30), Paint()..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4));
    canvas.drawRRect(glow, Paint()..color = Colors.white);
    canvas.drawRRect(
      glow,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..shader = SweepGradient(
          colors: _glowColors,
          stops: _glowStops,
          transform: rotation,
        ).createShader(glow.outerRect),
    );
    canvas.restore();

    // 알약: 흰 바탕 + 바깥쪽 2px 선. 한쪽(처음엔 오른쪽)이 진한 파랑, 반대쪽(처음엔 왼쪽)이 연한 파랑.
    // 연한 쪽은 아이콘 원의 밝은 테두리와 늘 같은 방향을 향해 함께 돈다.
    final pill = RRect.fromRectAndRadius(rect, const Radius.circular(100));
    canvas.drawRRect(pill, Paint()..color = pressed ? AppColors.brandSoft : Colors.white);
    canvas.drawRRect(
      pill.inflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = SweepGradient(
          colors: const [_blue, _light, _light, _blue],
          stops: const [0, 0.3, 0.7, 1],
          transform: rotation,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_AiPillPainter old) => old.pressed != pressed || old.turns != turns;
}

/// AI 알약 안의 동그란 "+" 아이콘. 피그마 Frame 290(218:11185)을 SVG로 뽑은 값 그대로:
/// 21 원 #2F5598 위에 원형 그라디언트(중심 (7.65, 7.65), 반지름 14.24: 투명 → 76.9% #004FED → #A0D5FF),
/// 흰 +는 피그마 벡터 경로(assets/images/kit/ai_orb_plus.svg).
class AxisAiPlusOrb extends StatelessWidget {
  const AxisAiPlusOrb({super.key, this.size = 21, this.turns});

  final double size;

  /// 주면 원형 그라디언트(밝은 테두리)가 이 값(0~1)만큼 원을 따라 돈다. + 는 그대로.
  final Animation<double>? turns;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PlusOrbPainter(turns ?? const AlwaysStoppedAnimation(0)),
        child: SvgPicture.asset('assets/images/kit/ai_orb_plus.svg', width: size, height: size),
      ),
    );
  }
}

class _PlusOrbPainter extends CustomPainter {
  _PlusOrbPainter(this.turns) : super(repaint: turns);

  final Animation<double> turns;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final c = rect.center;
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF2F5598));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: _center(turns.value),
          radius: 14.2382 / 21,
          colors: const [Color(0x00000000), Color(0xFF004FED), Color(0xFFA0D5FF)],
          stops: const [0, 0.769231, 1],
        ).createShader(rect),
    );
  }

  /// 그라디언트 중심. 밝은 테두리는 중심 반대쪽에 생기므로, 알약 선의 밝은(연한) 쪽(처음엔 왼쪽 180°)과
  /// 같은 방향이 되도록 중심을 그 반대(처음엔 오른쪽 0°)에 두고 선과 같은 속도로 돌린다.
  static Alignment _center(double t) {
    final a = t * 2 * math.pi;
    const r = 2.85 * math.sqrt2 / 10.5;
    return Alignment(r * math.cos(a), r * math.sin(a));
  }

  @override
  bool shouldRepaint(_PlusOrbPainter old) => old.turns != turns;
}
