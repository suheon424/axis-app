import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';
import 'kit_buttons.dart';
import 'progress.dart';
import 'selection.dart';

/// 목록 줄 사이 1px 구분선(#EDEEF6).
class AxisDivider extends StatelessWidget {
  const AxisDivider({super.key, this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent),
      height: 1,
      color: AppColors.gray02,
    );
  }
}

/// Divider/Section(130:9839): 섹션 사이 8px 회색 띠(#F4F5FA). 화면 가로 끝까지.
class AxisSectionDivider extends StatelessWidget {
  const AxisSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: AppColors.gray01);
  }
}

/// 섹션 제목(20 Bold) + 오른쪽 선택 위젯(예: "전체보기").
class AxisSectionTitle extends StatelessWidget {
  const AxisSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(text, style: AxisText.sectionTitle)),
        ?trailing,
      ],
    );
  }
}

/// 설정 화면의 그룹 라벨(12 SemiBold gray06). 위 24 · 아래 4 여백.
class AxisGroupLabel extends StatelessWidget {
  const AxisGroupLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 4),
      child: Text(text, style: AxisText.groupLabel),
    );
  }
}

/// Setting Row/Basic(130:9848) · Setting Row/Description(130:9844).
/// 제목만 있으면 16 SemiBold, [description]이 있으면 제목 16 Medium + 설명 13 Regular #8B95A1.
/// [value]와 [onChanged]를 주면 오른쪽에 [AxisToggle]이 붙고, 아니면 [trailing]을 쓴다.
class AxisSettingRow extends StatelessWidget {
  const AxisSettingRow({
    super.key,
    required this.title,
    this.description,
    this.value,
    this.onChanged,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? description;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final right =
        trailing ?? (value != null ? AxisToggle(value: value!, onChanged: onChanged, semanticLabel: title) : null);
    final hasDesc = description != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? (value != null && onChanged != null ? () => onChanged!(!value!) : null),
      child: Container(
        constraints: BoxConstraints(minHeight: hasDesc ? 72 : 60),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: hasDesc
                        ? AxisText.rowTitleMedium.copyWith(color: AppColors.text)
                        : AxisText.rowTitle.copyWith(color: AppColors.text),
                  ),
                  if (hasDesc) ...[
                    const SizedBox(height: 4),
                    Text(description!, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.subIcon)),
                  ],
                ],
              ),
            ),
            if (right != null) ...[const SizedBox(width: 12), right],
          ],
        ),
      ),
    );
  }
}

/// List/Menu Row(130:10244): 18px 메뉴 아이콘 + 라벨(16 Medium) + (값) + 오른쪽 화살표. 높이 56, 누르면 #F4F5FA.
class AxisMenuRow extends StatelessWidget {
  const AxisMenuRow({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.value,
    this.showChevron = true,
  });

  final String label;
  final VoidCallback? onTap;

  /// [KitIcon]의 menu* 이름(예: KitIcon.menuBadge). 없으면 아이콘 자리 없이 시작.
  final String? icon;

  /// 화살표 앞의 회색 값(예: 버전 "11.23.0").
  final String? value;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: value == null ? label : '$label, $value',
      onTap: onTap,
      scale: 1,
      builder: (context, pressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        constraints: const BoxConstraints(minHeight: 56),
        color: pressed ? AppColors.gray01 : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[AxisIcon(icon!, size: 18), const SizedBox(width: 14)],
            Expanded(
              child: Text(label, style: AxisText.rowTitleMedium.copyWith(color: Colors.black)),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(value!, style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.subIcon)),
            ],
            if (showChevron) ...[const SizedBox(width: 4), const AxisChevronRight(color: AppColors.gray05)],
          ],
        ),
      ),
    );
  }
}

/// List/Category Row(130:10034): 색 네모 + 카테고리 이름/실천 일수 + 미니 바 + 퍼센트 + 화살표. 아래 1px 선.
class AxisCategoryRow extends StatelessWidget {
  const AxisCategoryRow({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.percent,
    this.onTap,
  });

  final Color color;
  final String title;

  /// 예: "30일 중 18일 실천"
  final String subtitle;

  /// 0~100
  final int percent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray02)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AxisText.rowTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AxisText.caption),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AxisMiniBar(value: percent / 100, color: color),
            const SizedBox(width: 12),
            SizedBox(
              width: 44,
              child: Text('$percent%', textAlign: TextAlign.right, style: AxisText.rowTitle),
            ),
            if (onTap != null) const AxisChevronRight(size: 18, color: AppColors.gray05),
          ],
        ),
      ),
    );
  }
}
