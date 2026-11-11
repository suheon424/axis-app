import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';

/// Card/Category(130:9851): 흰 카드(굴곡 8, 안쪽 20) — 카테고리 이름(18 Bold) + "이번 달 18/30일" + 화살표,
/// 아래에 날짜 수만큼 작은 네모(10×9). 실천한 날은 [color], 나머지는 [color] 10%.
class AxisCategoryCard extends StatelessWidget {
  const AxisCategoryCard({
    super.key,
    required this.title,
    required this.days,
    this.color = AppColors.brand,
    this.periodLabel = '이번 달',
    this.onTap,
  });

  final String title;

  /// 하루에 하나씩, 실천했으면 true.
  final List<bool> days;
  final Color color;
  final String periodLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = days.where((d) => d).length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.3,
                      letterSpacing: -0.09,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  periodLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.36,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray05,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '$done/${days.length}일',
                  style: const TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                const Spacer(),
                if (onTap != null) const AxisChevronRight(size: 21, color: AppColors.gray05),
              ],
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Wrap(
                spacing: 3.6,
                runSpacing: 4,
                children: [
                  for (final d in days)
                    Container(
                      width: 10,
                      height: 9,
                      decoration: BoxDecoration(
                        color: d ? color : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card/Template Info 안의 회색 메타 칩(시계 + "3달 소요"). 굴곡 4, 높이 20.
class AxisMetaChip extends StatelessWidget {
  const AxisMetaChip(this.label, {super.key, this.icon = KitIcon.clockSmall});

  final String label;

  /// [KitIcon] 이름. null이면 글자만.
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[AxisIcon(icon!, size: 12), const SizedBox(width: 3)],
          Text(
            label,
            style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.gray06),
          ),
        ],
      ),
    );
  }
}

/// Card/Template Info(130:10097): 템플릿 제목(16 SemiBold) + 한 줄 설명(12 Medium 회색)
/// + 아래 줄에 메타 칩과 오른쪽 "댓글 99+ · 작성자".
class AxisTemplateInfo extends StatelessWidget {
  const AxisTemplateInfo({super.key, required this.title, this.description, this.meta, this.footnote});

  final String title;
  final String? description;

  /// 예: "3달 소요"
  final String? meta;

  /// 예: "댓글 99+ · 매력둥이gdken"
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AxisText.rowTitle.copyWith(color: Colors.black)),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: const TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: Color(0xFF999999)),
          ),
        ],
        if (meta != null || footnote != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (meta != null) AxisMetaChip(meta!),
              const SizedBox(width: 12),
              if (footnote != null)
                Expanded(
                  child: Text(
                    footnote!,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.36,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray06,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
