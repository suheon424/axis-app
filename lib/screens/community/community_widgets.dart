import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'community_data.dart';

const communityText = Color(0xFF191F28);
const communityBody = Color(0xFF4E5968);
const communitySub = Color(0xFF6B7684);
const communityLine = Color(0xFFF2F4F6);
const starColor = Color(0xFFFFB020);

/// 색 원 안의 캐릭터 얼굴(후기·댓글·작성자 아바타).
class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar(this.user, {super.key, this.size = 36});

  final CommunityUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: user.name,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: user.color, shape: BoxShape.circle),
        child: Stack(
          children: [
            Positioned(
              left: size * 0.14,
              right: size * 0.14,
              top: size * 0.08,
              child: Image.asset(AxisAvatar.asset(user.character), fit: BoxFit.fitWidth),
            ),
          ],
        ),
      ),
    );
  }
}

/// 노란 별점. [filled]개는 노랑, 나머지는 회색.
class StarRow extends StatelessWidget {
  const StarRow({super.key, this.filled = 5, this.count = 5, this.size = 14, this.gap = 0});

  final int filled;
  final int count;
  final double size;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '별점 $filled점',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Icon(Icons.star_rounded, size: size, color: i < filled ? starColor : const Color(0xFFE5E8EB)),
          ],
        ],
      ),
    );
  }
}

/// 09 인기 템플릿 한 줄: 82px 썸네일(순위·북마크) + Card/Template Info.
class TemplateRow extends StatelessWidget {
  const TemplateRow({
    super.key,
    required this.template,
    required this.onTap,
    this.bookmarked = false,
    this.onBookmark,
    this.first = false,
  });

  final CommunityTemplate template;
  final VoidCallback onTap;
  final bool bookmarked;
  final VoidCallback? onBookmark;

  /// 목록 첫 줄(09-5): 위 여백 없이 붙고 아래만 17.
  final bool first;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      onTap: onTap,
      semanticLabel: template.title,
      builder: (context, pressed) => Container(
        padding: first ? const EdgeInsets.only(bottom: 16) : const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFDEE2E6))),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 82,
              height: 82,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(template.thumb, fit: BoxFit.cover),
                    ),
                  ),
                  AxisRankBadge(template.rank, top: template.rank == 1),
                  Positioned(
                    right: 4,
                    bottom: 6,
                    child: GestureDetector(
                      onTap: onBookmark,
                      child: Semantics(
                        button: true,
                        label: bookmarked ? '북마크 해제' : '북마크',
                        excludeSemantics: true,
                        child: AxisIcon(bookmarked ? KitIcon.navBookmarkOn : KitIcon.navBookmark, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 25),
            Expanded(
              child: AxisTemplateInfo(
                title: template.title,
                description: template.description,
                meta: template.duration,
                footnote: template.footnote,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 09 · 로딩: 템플릿 줄 자리의 스켈레톤.
class TemplateRowSkeleton extends StatelessWidget {
  const TemplateRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.all(Radius.circular(8)), child: AxisSkeletonBar(width: 82, height: 82)),
          SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AxisSkeletonBar(width: 180, height: 18),
                SizedBox(height: 12),
                AxisSkeletonBar(width: null, height: 12),
                SizedBox(height: 18),
                AxisSkeletonBar(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 검색 결과 없음 · 댓글 빈 상태: 회색 원 아이콘 + 제목 + 설명(+ 흰 테두리 버튼).
class CommunityEmpty extends StatelessWidget {
  const CommunityEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
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
          decoration: const BoxDecoration(color: AppColors.gray01, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: AppColors.gray06),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.gray07),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          textAlign: TextAlign.center,
          style: AxisText.body.copyWith(color: AppColors.gray06),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 16),
          PressBuilder(
            onTap: onAction,
            semanticLabel: actionLabel,
            builder: (context, pressed) => Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: pressed ? AppColors.gray01 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.chipBorder),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.gray07),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 흰 바탕 섹션(좌우 20, 위아래 24). 섹션 사이는 회색(#F4F5FA) 8px 틈.
class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 24)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, color: Colors.white, padding: padding, child: child);
  }
}

/// 섹션 머리: 20 Bold 제목 + 오른쪽 글자 버튼.
class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.title, this.action, this.onAction, this.actionColor = AppColors.brand});

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AxisText.sectionTitle.copyWith(color: communityText)),
        ),
        if (action != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: Semantics(
              button: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 32),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action!,
                      style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: actionColor),
                    ),
                    if (actionColor != AppColors.brand) AxisChevronRight(size: 16, color: actionColor),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "준비물 6개 모두 보기 ⌄" 같은 테두리 링크 버튼.
class DetailMoreLink extends StatelessWidget {
  const DetailMoreLink({super.key, required this.label, required this.onTap, this.expanded = false});

  final String label;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: pressed ? AppColors.gray01 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.gray06),
              ),
            ),
            const SizedBox(width: 2),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const AxisIcon(KitIcon.chevronDownSmall, size: 16, color: AppColors.gray06),
            ),
          ],
        ),
      ),
    );
  }
}

/// 회색 바탕 통계 세 칸(기간·하루·북마크 / 담은 횟수·평균 달성률·합격 인증).
class StatStrip extends StatelessWidget {
  const StatStrip(this.stats, {super.key});

  final List<PlanStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE5E8EB)),
                ),
              Expanded(
                child: Column(
                  children: [
                    Text(stats[i].label, style: AxisText.caption),
                    Text(
                      stats[i].value,
                      style: AxisText.rowTitle.copyWith(color: stats[i].highlight ? AppColors.brand : communityText),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
