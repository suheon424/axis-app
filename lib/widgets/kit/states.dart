import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';
import 'kit_buttons.dart';

/// State/Empty(130:9988): 56px 회색 원 안 아이콘 + 제목(16 SemiBold) + 설명(14 Regular) + 작은 버튼.
class AxisEmptyState extends StatelessWidget {
  const AxisEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = KitIcon.navBookmark,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;

  /// [KitIcon] 이름(24px 선 아이콘).
  final String icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.gray01, shape: BoxShape.circle),
          child: AxisIcon(icon),
        ),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: AxisText.rowTitle),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: AxisText.body.copyWith(color: AppColors.gray06),
          ),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: 16),
          AxisSmallButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    );
  }
}

/// Coachmark/Bottom Bar(130:10149): 코치마크(어두운 덮개) 아래쪽 "다시 보지 않기" 체크 + "닫기" 테두리 버튼.
class AxisCoachmarkBottomBar extends StatelessWidget {
  const AxisCoachmarkBottomBar({
    super.key,
    required this.dontShowAgain,
    required this.onDontShowAgainChanged,
    required this.onClose,
    this.checkLabel = '다시 보지 않기',
    this.closeLabel = '닫기',
  });

  final bool dontShowAgain;
  final ValueChanged<bool> onDontShowAgainChanged;
  final VoidCallback onClose;
  final String checkLabel;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            checked: dontShowAgain,
            label: checkLabel,
            excludeSemantics: true,
            onTap: () => onDontShowAgainChanged(!dontShowAgain),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onDontShowAgainChanged(!dontShowAgain),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: dontShowAgain ? AppColors.brand : Colors.transparent,
                      shape: BoxShape.circle,
                      border: dontShowAgain ? null : Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: dontShowAgain ? const AxisIcon(KitIcon.checkWhite, size: 22) : null,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(checkLabel, style: AxisText.rowTitleMedium.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: closeLabel,
          excludeSemantics: true,
          onTap: onClose,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Text(closeLabel, style: AxisText.button),
            ),
          ),
        ),
      ],
    );
  }
}
