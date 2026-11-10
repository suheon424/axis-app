import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'kit_buttons.dart';

/// 화면 아래 떠 있는 AI 알약 버튼(07_05·07_06·07_07 "틀어진 일정 맞추기", 07_09 "동선 최적화하기").
///
/// 시안(07_07 J모드 · 제안 펼침_이동/삭제 Frame 278): 흰 알약 + 바깥쪽 1px 선(왼쪽 #A3C1F5 → 오른쪽 #1C67EF),
/// 뒤에 파란 각도 그라디언트 선(1.4)을 가진 조금 큰 알약을 흐림 8로 번지게 깐다.
/// 선과 번짐의 그라디언트는 [spinDuration]마다 360° 돈다(0801 입력창과 같은 빠르기).
class AxisAiPill extends StatefulWidget {
  const AxisAiPill({super.key, required this.icon, required this.label, required this.onTap});

  final Widget icon;
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
              widget.icon,
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

    // 알약: 흰 바탕 + 바깥쪽 1px 선. 한쪽(처음엔 오른쪽)이 진한 파랑, 반대쪽이 연한 파랑.
    final pill = RRect.fromRectAndRadius(rect, const Radius.circular(100));
    canvas.drawRRect(pill, Paint()..color = pressed ? AppColors.brandSoft : Colors.white);
    canvas.drawRRect(
      pill.inflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
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

/// AI 알약 안의 동그란 "+" 아이콘(시안 AI/Orb Frame 290): 남색 #2F5498 위에 가운데는 비고 가장자리로
/// #004FED → #A0D5FF로 밝아지는 원형 그라디언트(중심은 오른쪽 위), 흰 + 10.5.
class AxisAiPlusOrb extends StatelessWidget {
  const AxisAiPlusOrb({super.key, this.size = 21});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x260D0C48), blurRadius: 10)],
      ),
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _PlusOrbPainter()),
      ),
    );
  }
}

class _PlusOrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final c = rect.center;
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF2F5498));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.27, -0.27),
          radius: 0.678,
          colors: [Color(0x00000000), Color(0xFF004FED), Color(0xFFA0D5FF)],
          stops: [0, 0.769, 1],
        ).createShader(rect),
    );
    // 흰 + (10.5 / 21 크기, 굵기 약 3).
    final arm = size.width * 0.25;
    final t = size.width * 0.14;
    final white = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: arm * 2, height: t), Radius.circular(t / 2)),
      white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: t, height: arm * 2), Radius.circular(t / 2)),
      white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
