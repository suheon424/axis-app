import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

/// 07 화면의 axis AI 오브(파란 유리구슬 + 흰 십자). 피그마 이미지 대신 그려서 어떤 크기에도 선명하다.
class ListAiOrb extends StatelessWidget {
  const ListAiOrb({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _OrbPainter()),
    );
  }
}

class _OrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.45),
          radius: 1.05,
          colors: [Color(0xFFF2F7FF), Color(0xFF9CC2FF), Color(0xFF3A7BFF), Color(0xFF0B4BD0)],
          stops: [0.0, 0.32, 0.72, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // 가장자리의 얇은 밝은 테
    canvas.drawCircle(
      c,
      r - r * 0.04,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    final arm = r * 0.42;
    final plus = Paint()
      ..color = Colors.white
      ..strokeWidth = r * 0.24
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c.translate(-arm, 0), c.translate(arm, 0), plus);
    canvas.drawLine(c.translate(0, -arm), c.translate(0, arm), plus);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 07_05-1 분석 중 화면의 회전하는 링(파란 원뿔 그라디언트 + 보랏빛 번짐).
class ListAiRing extends StatelessWidget {
  const ListAiRing({super.key, required this.turns, required this.progress});

  final double turns;
  final double progress;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RingPainter(turns, progress));
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.turns, this.progress);

  final double turns;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0xCC8B7BFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0xFF0B1E4A),
    );
    final start = -math.pi / 2 + turns * 2 * math.pi;
    canvas.drawArc(
      rect,
      start,
      2 * math.pi * (0.25 + 0.75 * progress),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          transform: GradientRotation(start),
          colors: const [Color(0xFF003DAB), Color(0xFF005BF0), Color(0xFF126BFF), Color(0xFF005EFF)],
          stops: const [0.0, 0.15, 0.34, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.turns != turns || old.progress != progress;
}

/// 일반 모드 체크박스(18, 굴곡 4): 켜면 파란 채움 + 흰 체크.
class ListCheckbox extends StatelessWidget {
  const ListCheckbox({super.key, required this.checked, required this.onTap, required this.label, this.jMode = false});

  final bool checked;
  final VoidCallback onTap;
  final String label;
  final bool jMode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: '$label 완료',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // 눈에 보이는 상자는 18이지만 누르는 영역은 44로 넓힌다.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: checked ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: checked ? AppColors.primary : (jMode ? AppColors.checkboxBorder : AppColors.gray03),
                  width: jMode && !checked ? 1.5 : 1,
                ),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: checked ? 1 : 0,
                child: SvgPicture.asset('assets/icons/list_check.svg', width: 18, height: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "틀어진 일정 맞추기" 알약 버튼(파란 테두리 + 뒤로 번지는 파란 빛).
class ListFixButton extends StatelessWidget {
  const ListFixButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '틀어진 일정 맞추기',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0xFF005BF1)),
            boxShadow: const [BoxShadow(color: Color(0x66005BF1), blurRadius: 8, spreadRadius: 0.5)],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x260D0C48), blurRadius: 10)],
                ),
                child: ListAiOrb(size: 22),
              ),
              SizedBox(width: 8),
              Text(
                '틀어진 일정 맞추기',
                style: TextStyle(fontSize: 16, height: 14 / 16, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 가로 그라디언트 글자(J모드 제안 문구, AI 일정 제안 머리글).
class ListGradientText extends StatelessWidget {
  const ListGradientText(this.text, {super.key, required this.colors, required this.style});

  final String text;
  final List<Color> colors;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => LinearGradient(colors: colors).createShader(rect),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

/// 아이콘 하나짜리 탭 영역 44 버튼.
class ListIconButton extends StatelessWidget {
  const ListIconButton({super.key, required this.asset, required this.label, required this.onTap, this.size = 24});

  final String asset;
  final String label;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(asset, width: size, height: size),
          ),
        ),
      ),
    );
  }
}
