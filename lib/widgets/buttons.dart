import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 누르는 동안 살짝 줄어드는 탭 피드백.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.97});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// 파란 그라디언트 메인 버튼. [enabled]가 false면 회색으로 바뀐다(로그인 화면 02 → 03).
class BrandButton extends StatelessWidget {
  const BrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w700,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          height: AppSizes.buttonHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(decoration: BoxDecoration(gradient: brandButtonGradient)),
                AnimatedOpacity(
                  opacity: enabled ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: const ColoredBox(color: AppColors.gray05),
                ),
                Center(
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: fontWeight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 회색 보조 버튼(건너뛰기).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      child: Container(
        height: AppSizes.buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.skipBg, borderRadius: BorderRadius.circular(8)),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.skipText, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
