import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'community_data.dart';
import 'community_widgets.dart';
import 'plan_overview_tab.dart';

/// 0902 후기 탭: 평점 요약·분포·통계 → 필터(합격 인증·사진)·정렬 → 후기 목록.
class PlanReviewsTab extends StatefulWidget {
  const PlanReviewsTab({super.key, required this.onToast});

  final ToastFn onToast;

  @override
  State<PlanReviewsTab> createState() => _PlanReviewsTabState();
}

class _PlanReviewsTabState extends State<PlanReviewsTab> {
  bool _passedOnly = false;
  bool _photoOnly = false;
  bool _latest = false;
  final Set<int> _helpful = {};

  @override
  Widget build(BuildContext context) {
    var reviews = [
      for (var i = 0; i < planReviews.length; i++)
        if ((!_passedOnly || planReviews[i].passed) && (!_photoOnly || planReviews[i].photos.isNotEmpty)) i,
    ];
    if (_latest) reviews = [...reviews]..sort((a, b) => planReviews[b].date.compareTo(planReviews[a].date));
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const DetailSection(child: _Summary()),
        const SizedBox(height: 8),
        DetailSection(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            children: [
              Row(
                children: [
                  _FilterChip(
                    label: '합격 인증 23',
                    on: _passedOnly,
                    onTap: () => setState(() => _passedOnly = !_passedOnly),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(label: '사진 24', on: _photoOnly, onTap: () => setState(() => _photoOnly = !_photoOnly)),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _latest = !_latest),
                    child: Semantics(
                      button: true,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 33),
                        child: Row(
                          children: [
                            Text(
                              _latest ? '최신순' : '추천순',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.33,
                                fontWeight: FontWeight.w500,
                                color: communityBody,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const AxisIcon(KitIcon.chevronDownSmall, size: 14, color: communityBody),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final i in reviews)
                _ReviewItem(
                  review: planReviews[i],
                  helpful: _helpful.contains(i),
                  onHelpful: () => setState(() => _helpful.contains(i) ? _helpful.remove(i) : _helpful.add(i)),
                ),
              if (reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('조건에 맞는 후기가 없어요', style: AxisText.body),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onToast('후기를 더 불러오는 중이에요'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: const Text(
                    '후기 125개 더보기',
                    style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: communityBody),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    final max = reviewDistribution.reduce((a, b) => a + b);
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 110,
              child: Column(
                children: [
                  Text(
                    '4.8',
                    style: TextStyle(fontSize: 28, height: 1.3, fontWeight: FontWeight.w700, color: communityText),
                  ),
                  SizedBox(height: 4),
                  StarRow(size: 16, gap: 1),
                  SizedBox(height: 4),
                  Text('후기 128개', style: AxisText.caption),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  for (var s = 0; s < 5; s++)
                    Padding(
                      padding: EdgeInsets.only(top: s == 0 ? 0 : 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              '${5 - s}점',
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.33,
                                fontWeight: FontWeight.w500,
                                color: communitySub,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: reviewDistribution[s] / max,
                                minHeight: 6,
                                backgroundColor: communityLine,
                                color: AppColors.brand,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${reviewDistribution[s]}',
                              textAlign: TextAlign.right,
                              style: AxisText.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const StatStrip(reviewInsights),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: on,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 33),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: on ? AppColors.brandSoft : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: on ? AppColors.brand : AppColors.chipBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: on ? AppColors.brand : communityBody,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review, required this.helpful, required this.onHelpful});

  final PlanReview review;
  final bool helpful;
  final VoidCallback onHelpful;

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(fontSize: 12, height: 1.33, fontWeight: FontWeight.w500, color: AppColors.gray06);
    const value = TextStyle(color: AppColors.tabLabelOn);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: communityLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommunityAvatar(review.user),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  review.user.name,
                  style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: communityText),
                ),
              ),
              if (review.passed) ...[const SizedBox(width: 6), const AxisTag('합격 인증', tone: AxisTagTone.green)],
            ],
          ),
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                for (final p in review.photos)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(p, width: 88, height: 88, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(4)),
            child: Text.rich(
              TextSpan(
                text: '실천 기간',
                children: [
                  const TextSpan(text: ' 4주 ', style: value),
                  const TextSpan(text: '· 달성률'),
                  TextSpan(text: ' ${review.rate}%', style: value),
                ],
              ),
              style: label,
            ),
          ),
          const SizedBox(height: 10),
          Text(review.body, style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF333D4B))),
          const SizedBox(height: 10),
          Row(
            children: [
              StarRow(filled: review.stars),
              const SizedBox(width: 6),
              Expanded(child: Text(review.date, style: AxisText.caption)),
              AxisHelpfulButton(count: review.helpful + (helpful ? 1 : 0), selected: helpful, onPressed: onHelpful),
            ],
          ),
        ],
      ),
    );
  }
}
