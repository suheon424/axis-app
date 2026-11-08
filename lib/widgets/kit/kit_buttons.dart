import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../buttons.dart';
import 'icons.dart';
import 'shapes.dart';

/// 누르고 있는 동안 [builder]에 pressed=true를 넘겨 눌림 색을 그리게 한다.
class PressBuilder extends StatefulWidget {
  const PressBuilder({super.key, required this.builder, this.onTap, this.semanticLabel, this.scale = 0.98});

  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double scale;

  @override
  State<PressBuilder> createState() => _PressBuilderState();
}

class _PressBuilderState extends State<PressBuilder> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.builder(context, _down),
        ),
      ),
    );
  }
}

/// Button(130:9184) Type=Primary: 오른쪽 끝이 사선으로 잘린 메인 CTA(높이 52, 16 SemiBold).
/// 필수 입력이 끝나기 전에는 [enabled]=false → 회색(Disabled). 누르면 진한 파랑(Pressed).
class AxisCtaButton extends StatelessWidget {
  const AxisCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.onDisabledPressed,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  /// 비활성 상태에서 눌렀을 때 동작(예: 빠진 입력 안내). 없으면 아무 일 없다.
  final VoidCallback? onDisabledPressed;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: label,
      scale: 1,
      onTap: enabled ? onPressed : onDisabledPressed,
      builder: (context, pressed) {
        final body = !enabled
            ? AppColors.disabledFill
            : pressed
            ? AppColors.brandPressed
            : AppColors.brand;
        final corner = !enabled
            ? AppColors.disabledCorner
            : pressed
            ? AppColors.brandCornerPressed
            : AppColors.brandCorner;
        return CustomPaint(
          painter: _CtaPainter(body: body, corner: corner),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.buttonHeight),
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AxisText.button.copyWith(
                fontFamily: 'Pretendard',
                color: enabled ? Colors.white : AppColors.gray06,
              ),
              textAlign: TextAlign.center,
              child: Text(label),
            ),
          ),
        );
      },
    );
  }
}

class _CtaPainter extends CustomPainter {
  const _CtaPainter({required this.body, required this.corner});

  final Color body;
  final Color corner;

  @override
  void paint(Canvas canvas, Size size) {
    // 피그마 Button(130:9184) Type=Primary 그대로: 버튼 전체를 굴곡 8로 잘라(clip) 두고,
    // 몸통(위 343 → 아래 312로 기우는 사선)과 오른쪽 조각(350,0 → 319,52 사선)을 뾰족한 다각형으로 그린다.
    // 그래서 오른쪽 조각의 위 끝도 굴곡 8로 깎여 보인다.
    final w = size.width, h = size.height;
    final s = h * 31 / 52;
    const gap = 7.0;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)));
    canvas.drawPath(
      Path()..addPolygon([Offset.zero, Offset(w - gap, 0), Offset(w - gap - s, h), Offset(0, h)], true),
      Paint()..color = body,
    );
    canvas.drawPath(Path()..addPolygon([Offset(w, 0), Offset(w, h), Offset(w - s, h)], true), Paint()..color = corner);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CtaPainter old) => old.body != body || old.corner != corner;
}

/// 두 버튼을 사선으로 나눠 붙인 버튼 쌍.
enum AxisSplitTone {
  /// Button Type=2Primary: 왼쪽 회색 보조(gray06 글자) + 오른쪽 파란 메인. 높이 52.
  blue,

  /// Dialog/Confirm 버튼: 왼쪽 빨간 채움(위험한 메인) + 오른쪽 빨간 테두리 보조. 높이 40.
  red,
}

/// Button Type=2Primary(130:9184) / Dialog/Confirm(130:9948)의 사선으로 나뉜 두 버튼.
/// [AxisSplitTone.blue]: [leftLabel]=보조(회색), [rightLabel]=메인(파랑).
/// [AxisSplitTone.red]: [leftLabel]=메인(빨강 채움), [rightLabel]=보조(빨강 테두리).
class AxisSplitButton extends StatelessWidget {
  const AxisSplitButton({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeft,
    required this.onRight,
    this.tone = AxisSplitTone.blue,
    this.rightEnabled = true,
    this.height,
  });

  final String leftLabel;
  final String rightLabel;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  final AxisSplitTone tone;

  /// blue 톤에서 오른쪽 메인 버튼의 활성 여부(필수 선택 전에는 false → 회색).
  final bool rightEnabled;

  /// 최소 높이. 기본은 blue 52 / red 40(대화상자 안에서는 40을 쓴다).
  final double? height;

  @override
  Widget build(BuildContext context) {
    final red = tone == AxisSplitTone.red;
    final h = height ?? (red ? 40.0 : AppSizes.buttonHeight);
    final r = h < 48 ? 6.4 : 8.0;
    final leftFill = red ? AppColors.error : AppColors.gray03;
    final leftText = red ? Colors.white : AppColors.gray06;
    final rightFill = red ? null : (rightEnabled ? AppColors.brand : AppColors.disabledFill);
    final rightStroke = red ? AppColors.error : null;
    final rightText = red ? AppColors.error : (rightEnabled ? Colors.white : AppColors.gray06);
    final style = AxisText.button.copyWith(fontFamily: 'Pretendard');

    // 두 칸 중 글자가 더 긴 쪽에 맞춰 같은 높이로 늘어난다.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PressBuilder(
              semanticLabel: leftLabel,
              scale: 1,
              onTap: onLeft,
              builder: (_, _) => CustomPaint(
                painter: PolygonPainter(
                  fill: leftFill,
                  build: (s) => _half(s, left: true, r: r, figma: !red),
                ),
                child: _label(leftLabel, style.copyWith(color: leftText), h),
              ),
            ),
          ),
          Expanded(
            child: PressBuilder(
              semanticLabel: rightLabel,
              scale: 1,
              onTap: red || rightEnabled ? onRight : null,
              builder: (_, _) => CustomPaint(
                painter: PolygonPainter(
                  fill: rightFill,
                  stroke: rightStroke,
                  strokeWidth: 0.8,
                  build: (s) => _half(s, left: false, r: r, figma: !red),
                ),
                child: _label(rightLabel, style.copyWith(color: rightText), h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, TextStyle style, double h) => Container(
    constraints: BoxConstraints(minHeight: h),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    child: Text(text, style: style, textAlign: TextAlign.center),
  );

  /// 각 반쪽은 가운데 이음매 쪽이 사선(위가 오른쪽으로 기움, 높이 52에 가로 35.5)이고 사이에 약 8px 틈이 있다.
  /// 이음매의 뾰족한 모서리는 4, 둔한 모서리는 5만큼 둥글다(피그마 2Primary 130:9195 SVG).
  /// [figma]=false(red 대화상자 버튼)는 예전 모양(사선 0.6h, 틈 6, 뾰족한 이음매)을 그대로 쓴다.
  static Path _half(Size size, {required bool left, required double r, bool figma = true}) {
    final w = size.width, h = size.height;
    final s = figma ? h * 35.5 / 52 : h * 0.6;
    final g = figma ? 3.95 : 3.0; // 반쪽마다 틈의 절반
    final sharp = figma ? 4.0 : 0.0, blunt = figma ? 5.0 : 0.0;
    if (left) {
      return roundedPolygon(
        [const Offset(0.4, 0.4), Offset(w + s / 2 - g, 0.4), Offset(w - s / 2 - g, h - 0.4), Offset(0.4, h - 0.4)],
        [r, sharp, blunt, r],
      );
    }
    return roundedPolygon(
      [Offset(s / 2 + g, 0.4), Offset(w - 0.4, 0.4), Offset(w - 0.4, h - 0.4), Offset(-s / 2 + g, h - 0.4)],
      [blunt, r, r, sharp],
    );
  }
}

/// Button/Small(130:9975): 높이 40·굴곡 8의 작은 버튼. 빈 상태·카드 안 행동에 쓴다.
/// [outline]이면 흰 바탕 + gray03 테두리. [enabled]=false면 Disabled 색.
class AxisSmallButton extends StatelessWidget {
  const AxisSmallButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outline = false,
    this.enabled = true,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outline;
  final bool enabled;

  /// true면 가로를 꽉 채운다.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: label,
      scale: 1,
      onTap: enabled ? onPressed : null,
      builder: (context, pressed) {
        final Color bg;
        final Color fg;
        Color? border;
        if (outline) {
          bg = pressed ? AppColors.gray01 : Colors.white;
          fg = enabled ? AppColors.gray07 : AppColors.gray05;
          border = enabled ? AppColors.gray03 : AppColors.gray02;
        } else {
          bg = !enabled
              ? AppColors.disabledFill
              : pressed
              ? AppColors.brandPressed
              : AppColors.brand;
          fg = enabled ? Colors.white : AppColors.gray05;
        }
        return Container(
          constraints: const BoxConstraints(minHeight: 40),
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: border == null ? null : Border.all(color: border),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: fg),
          ),
        );
      },
    );
  }
}

/// Button/Buy(130:9905): 흰 바탕·테두리·굴곡 4의 작은 버튼(기본 "구매").
class AxisBuyButton extends StatelessWidget {
  const AxisBuyButton({super.key, this.label = '구매', required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 26, minWidth: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.chipBorder),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.neutralText,
            ),
          ),
        ),
      ),
    );
  }
}

/// Button/Add Icon(130:9907): 36px 연파랑 원 + 파란 더하기.
class AxisAddIconButton extends StatelessWidget {
  const AxisAddIconButton({super.key, required this.onPressed, this.tooltip = '추가'});

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.brandSoft, shape: BoxShape.circle),
          child: const AxisIcon(KitIcon.navPlus, size: 18, color: AppColors.brand),
        ),
      ),
    );
  }
}

/// Button/Helpful(130:9910): 엄지 아이콘 + "도움돼요 N". [selected]면 파란색.
class AxisHelpfulButton extends StatelessWidget {
  const AxisHelpfulButton({
    super.key,
    required this.count,
    required this.onPressed,
    this.selected = false,
    this.label = '도움돼요',
  });

  final int count;
  final VoidCallback? onPressed;
  final bool selected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.brand : AppColors.neutralText;
    return Pressable(
      onTap: onPressed,
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label $count',
        excludeSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 30),
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandSoft : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: selected ? AppColors.brand : AppColors.chipBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AxisIcon(KitIcon.helpful, size: 16, color: selected ? AppColors.brand : null),
              const SizedBox(width: 4),
              Text(
                '$label $count',
                style: TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Button/Directions(130:9920): 파란 채움·굴곡 6의 "길찾기" 버튼(13 Bold).
class AxisDirectionsButton extends StatelessWidget {
  const AxisDirectionsButton({super.key, this.label = '길찾기', required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: label,
      onTap: onPressed,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: pressed ? AppColors.brandPressed : AppColors.brand,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

/// Button/Icon Back · Share · Bookmark(130:9916/9918/9973): 44px 아이콘 버튼.
/// [floating]이면 흰 원 + 그림자(지도·사진 위에 뜨는 뒤로가기).
class AxisIconButton extends StatelessWidget {
  const AxisIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.floating = false,
    this.color,
    this.iconSize = 24,
  });

  /// 뒤로가기(누르면 [onPressed] 없을 때 Navigator.maybePop).
  factory AxisIconButton.back({Key? key, VoidCallback? onPressed, bool floating = false}) =>
      AxisIconButton(key: key, icon: KitIcon.navBack, tooltip: '뒤로', floating: floating, onPressed: onPressed);

  /// [icon]은 [KitIcon] 이름.
  final String icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool floating;
  final Color? color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final tap = onPressed ?? (icon == KitIcon.navBack ? () => Navigator.of(context).maybePop() : null);
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      onTap: tap,
      child: Pressable(
        onTap: tap,
        scale: 0.92,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: floating
              ? const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x29000000), blurRadius: 14, offset: Offset(0, 4))],
                )
              : null,
          child: AxisIcon(icon, size: iconSize, color: color),
        ),
      ),
    );
  }
}

/// Button/Close(130:9213): 보이는 크기 32(아이콘 24), 누르는 영역 44.
class AxisCloseButton extends StatelessWidget {
  const AxisCloseButton({super.key, this.onPressed, this.color});

  /// 없으면 Navigator.maybePop.
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OverflowBox(
        maxWidth: 44,
        maxHeight: 44,
        child: Semantics(
          button: true,
          label: '닫기',
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed ?? () => Navigator.of(context).maybePop(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(child: AxisIcon(KitIcon.navClose, color: color)),
            ),
          ),
        ),
      ),
    );
  }
}
