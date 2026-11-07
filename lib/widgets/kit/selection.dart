import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';

/// Toggle(130:9834): 48×28 스위치. 켜짐 파랑 / 꺼짐 #E5E8EB, 흰 손잡이 22.
class AxisToggle extends StatelessWidget {
  const AxisToggle({super.key, required this.value, required this.onChanged, this.semanticLabel});

  final bool value;

  /// null이면 누를 수 없다.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: semanticLabel,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.brand : AppColors.toggleOff,
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 3, offset: Offset(0, 1))],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip(130:9287): 높이 44·굴곡 8 선택 칩(13 Medium). 선택되면 연파랑 바탕·파란 테두리·Bold.
class AxisChip extends StatelessWidget {
  const AxisChip({super.key, required this.label, required this.selected, required this.onTap, this.expand = false});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// true면 가로를 꽉 채운다(그리드 안에서).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 44),
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          alignment: expand ? Alignment.center : null,
          decoration: BoxDecoration(
            color: selected ? AppColors.blue01 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.brand : AppColors.chipBorder),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.brand : AppColors.body,
            ),
          ),
        ),
      ),
    );
  }
}

/// Radio(130:9373): 20px 원형 라디오. 켜지면 파란 테두리 + 가운데 점 10.
class AxisRadio extends StatelessWidget {
  const AxisRadio({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: selected ? AppColors.brand : AppColors.radioBorder, width: 1.5),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// ColorSwatch(130:9369): 16px 색 동그라미. 선택되면 흰 1px + 파란 4px 고리.
class AxisColorSwatch extends StatelessWidget {
  const AxisColorSwatch({super.key, required this.color, required this.selected, this.onTap, this.size = 16});

  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: selected ? Border.all(color: Colors.white) : null,
              boxShadow: selected ? const [BoxShadow(color: AppColors.brand, spreadRadius: 3)] : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stepper(130:9378): 회색 상자 안에 − / 값(22 Bold) + 설명(12 SemiBold) / +.
/// 높이는 최소 76이고 글자에 맞춰 늘어난다.
class AxisStepper extends StatelessWidget {
  const AxisStepper({super.key, required this.value, required this.onMinus, required this.onPlus, this.caption});

  /// 가운데 값 문구(예: "40분").
  final String value;
  final String? caption;

  /// null이면 그 버튼은 흐리게 보이고 눌리지 않는다.
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: AppColors.stepperBg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          _RoundButton(icon: '−', label: '줄이기', onTap: onMinus),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray07,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.caption,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _RoundButton(icon: '+', label: '늘리기', onTap: onPlus),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final plus = icon == '+';
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.chipBorder),
            ),
            child: plus
                ? const AxisIcon(KitIcon.navPlus, size: 21, color: AppColors.gray07)
                : Container(width: 12, height: 2.2, color: AppColors.gray07),
          ),
        ),
      ),
    );
  }
}
