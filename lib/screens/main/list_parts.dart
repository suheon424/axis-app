import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';

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

/// Checkbox(20, 굴곡 4): 켜면 파란 채움 + 흰 체크, 끄면 #B8BEC8 1.5 테두리. 누르는 영역은 44.
class ListCheckbox extends StatelessWidget {
  const ListCheckbox({super.key, required this.checked, required this.onTap, required this.label});

  final bool checked;
  final VoidCallback onTap;
  final String label;

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
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? AppColors.brand : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: checked ? AppColors.brand : AppColors.checkboxBorder, width: 1.5),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: checked ? 1 : 0,
                child: SvgPicture.asset('assets/icons/list_check.svg', width: 17, height: 17),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "틀어진 일정 맞추기" 떠 있는 알약([AxisAiPill]). 하단바 위 24에 고정.
class ListFixButton extends StatelessWidget {
  const ListFixButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AxisAiPill(label: '틀어진 일정 맞추기', onTap: onTap);
  }
}

/// 가로 그라디언트 글자(J모드 제안 문구).
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

/// 07_07 밀어서 드러나는 "이동 · 삭제" 사선 버튼 한 쌍(폭 [ListSwipeActions.width]).
/// 회색 "이동" 조각 위로 빨간 "삭제" 조각이 사선으로 겹친다.
class ListSwipeActions extends StatelessWidget {
  const ListSwipeActions({super.key, required this.onMove, required this.onDelete});

  static const width = 144.0;
  static const _slant = 28.0;

  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: _SwipePainter(),
        child: Row(children: [_hit('이동', AppColors.gray06, onMove), _hit('삭제', Colors.white, onDelete)]),
      ),
    );
  }

  Widget _hit(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const s = ListSwipeActions._slant;
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.gray02);
    final mid = w / 2;
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(mid + s / 2, 0)
        ..lineTo(mid - s / 2, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = AppColors.gray03,
    );
    canvas.drawPath(
      Path()
        ..moveTo(mid + s / 2 + 2, 0)
        ..lineTo(w, 0)
        ..lineTo(w, h)
        ..lineTo(mid - s / 2 + 2, h)
        ..close(),
      Paint()..color = AppColors.error,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
