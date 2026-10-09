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

/// Button/Primary: 파란 그라디언트 메인 버튼(높이 52, 글자 17 Bold, 굴곡 8).
/// 필수 입력이 끝나지 않았으면 [enabled]를 false로 두어 회색(Disabled)으로 보인다.
class BrandButton extends StatelessWidget {
  const BrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.onDisabledPressed,
    this.gradient = brandButtonGradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  /// 비활성 상태에서 눌렀을 때 동작(테스트용 자동 입력 등). 없으면 눌러도 아무 일 없다.
  final VoidCallback? onDisabledPressed;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onPressed : onDisabledPressed,
      child: Pressable(
        onTap: enabled ? onPressed : onDisabledPressed,
        child: SizedBox(
          height: AppSizes.buttonHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
                AnimatedOpacity(
                  opacity: enabled ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: const ColoredBox(color: AppColors.gray05),
                ),
                Center(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
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

/// 흰 바탕 + 테두리 보조 버튼(MBTI 시트의 "잘 모르겠어요").
class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Pressable(
        onTap: onPressed,
        child: Container(
          height: AppSizes.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.chipBorder),
          ),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.gray05, fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

/// 회색으로 채운 보조 버튼(06 프로필의 "다음에 설정하기").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Pressable(
        onTap: onPressed,
        child: Container(
          height: AppSizes.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.skipBg, borderRadius: BorderRadius.circular(8)),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.skipText, fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

/// Button/Text: 밑줄 글자 버튼(높이 40). 건너뛰기 같은 보조 행동에 쓴다.
class TextLinkButton extends StatelessWidget {
  const TextLinkButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Pressable(
        onTap: onPressed,
        child: SizedBox(
          height: 40,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.body,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
