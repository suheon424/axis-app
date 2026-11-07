import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'community_data.dart';
import 'community_widgets.dart';

typedef ToastFn = void Function(String message, {String? action, VoidCallback? onAction});

/// 0901 계획서 탭: 표지·요약 → 준비물 → 합격자 노하우 → 계획 순서 → 하루 루틴 → 작성자.
class PlanOverviewTab extends StatefulWidget {
  const PlanOverviewTab({
    super.key,
    required this.template,
    required this.bookmarked,
    required this.onBookmark,
    required this.onToast,
  });

  final CommunityTemplate template;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final ToastFn onToast;

  @override
  State<PlanOverviewTab> createState() => _PlanOverviewTabState();
}

class _PlanOverviewTabState extends State<PlanOverviewTab> {
  bool _allSupplies = false;
  bool _allRoutine = false;
  int _orderView = 0;
  final Set<int> _addedRoutine = {};
  final _routineKey = GlobalKey();

  void _toggleRoutine(int i) {
    final added = !_addedRoutine.contains(i);
    setState(() => added ? _addedRoutine.add(i) : _addedRoutine.remove(i));
    widget.onToast(added ? '내 계획표에 추가했어요' : '계획표에서 뺐어요');
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 8);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [_hero(), gap, _supplies(), gap, _knowHow(), gap, _order(), gap, _routine(), gap, _author()],
    );
  }

  Widget _hero() {
    final t = widget.template;
    return DetailSection(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 350 / 196,
                  child: Image.asset(t.cover ?? t.thumb, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: AxisIconButton(
                  icon: widget.bookmarked ? KitIcon.navBookmarkOn : KitIcon.navBookmark,
                  tooltip: widget.bookmarked ? '북마크 해제' : '북마크',
                  color: Colors.white,
                  onPressed: widget.onBookmark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AxisTag(t.category),
              AxisTag('인기 ${t.rank}위', tone: AxisTagTone.orange),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.title,
            style: const TextStyle(
              fontSize: 22,
              height: 1.3,
              letterSpacing: -0.22,
              fontWeight: FontWeight.w700,
              color: communityText,
            ),
          ),
          const SizedBox(height: 8),
          Text(planIntro, style: AxisText.body.copyWith(color: communityBody)),
          const SizedBox(height: 20),
          const StatStrip(planStats),
          const SizedBox(height: 20),
          const Text(
            '이런 분께 추천해요',
            style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: communitySub),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final a in planAudience) AxisTag(a, tone: AxisTagTone.neutral)],
          ),
        ],
      ),
    );
  }

  Widget _supplies() {
    final shown = _allSupplies ? planSupplies : planSupplies.take(3).toList();
    return DetailSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailHeader(
            title: '준비물',
            action: '한 번에 담기',
            onAction: () => widget.onToast('준비물 ${planSupplies.length}개를 담았어요'),
          ),
          const Text(
            '기본서',
            style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: communitySub),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < shown.length; i++)
            Container(
              constraints: const BoxConstraints(minHeight: 58),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i < shown.length - 1 ? const Border(bottom: BorderSide(color: communityLine)) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(shown[i].$1, style: AxisText.rowTitle.copyWith(color: communityText)),
                  ),
                  Text(shown[i].$2, style: AxisText.caption),
                  const SizedBox(width: 8),
                  AxisBuyButton(onPressed: () => widget.onToast('${shown[i].$1} 구매 페이지는 준비 중이에요')),
                ],
              ),
            ),
          const SizedBox(height: 12),
          DetailMoreLink(
            label: _allSupplies ? '준비물 접기' : '준비물 ${planSupplies.length}개 모두 보기',
            expanded: _allSupplies,
            onTap: () => setState(() => _allSupplies = !_allSupplies),
          ),
        ],
      ),
    );
  }

  Widget _knowHow() {
    return DetailSection(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DetailHeader(
              title: '합격자 노하우',
              action: '더보기',
              actionColor: AppColors.subIcon,
              onAction: () => widget.onToast('노하우 영상 모아보기는 준비 중이에요'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 134,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: planVideos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) =>
                  _VideoCard(video: planVideos[i], onTap: () => widget.onToast('${planVideos[i].title} 영상은 준비 중이에요')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _order() {
    return DetailSection(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('계획 순서', style: AxisText.sectionTitle.copyWith(color: communityText)),
              ),
              SizedBox(
                width: 176,
                child: AxisPillSegment(
                  labels: const ['주차별', '하루 루틴'],
                  selected: _orderView,
                  onChanged: (i) {
                    setState(() => _orderView = i);
                    if (i == 1 && _routineKey.currentContext != null) {
                      Scrollable.ensureVisible(
                        _routineKey.currentContext!,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < planSteps.length; i++)
            _StepRow(step: planSteps[i], number: i + 1, last: i == planSteps.length - 1),
        ],
      ),
    );
  }

  Widget _routine() {
    final shown = _allRoutine ? planRoutine : planRoutine.take(4).toList();
    return DetailSection(
      key: _routineKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: DetailHeader(
              title: '하루 루틴',
              action: '전체 담기',
              onAction: () {
                setState(() => _addedRoutine.addAll(List.generate(planRoutine.length, (i) => i)));
                widget.onToast('하루 루틴 ${planRoutine.length}개를 내 계획표에 담았어요');
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(6)),
            child: const Text(
              '＋를 누르면 내 계획표에 바로 추가돼요',
              style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w500, color: AppColors.brand),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < shown.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: communityLine)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      shown[i].$1,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.33,
                        fontWeight: FontWeight.w500,
                        color: communitySub,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shown[i].$2, style: AxisText.rowTitle.copyWith(color: communityText)),
                        const SizedBox(height: 2),
                        Text(shown[i].$3, style: AxisText.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AddRoutineButton(
                    added: _addedRoutine.contains(i),
                    label: shown[i].$2,
                    onTap: () => _toggleRoutine(i),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          DetailMoreLink(
            label: _allRoutine ? '하루 루틴 접기' : '하루 루틴 ${planRoutine.length}개 모두 보기',
            expanded: _allRoutine,
            onTap: () => setState(() => _allRoutine = !_allRoutine),
          ),
        ],
      ),
    );
  }

  Widget _author() {
    return DetailSection(
      child: Column(
        children: [
          Row(
            children: [
              const CommunityAvatar(author, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author.name, style: AxisText.rowTitle.copyWith(color: communityText)),
                    const SizedBox(height: 2),
                    const Text(authorBio, style: AxisText.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PressBuilder(
            onTap: () => widget.onToast('${author.name}님에게 포인트를 보냈어요'),
            semanticLabel: '포인트 보내기',
            builder: (context, pressed) => Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 52),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: pressed ? AppColors.gray01 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.chipBorder),
              ),
              child: Text('포인트 보내기', style: AxisText.rowTitle.copyWith(color: communityBody)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onTap});

  final PlanVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      onTap: onTap,
      semanticLabel: video.title,
      builder: (context, pressed) => SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: video.color, borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  if (video.thumb != null) Positioned.fill(child: Image.asset(video.thumb!, fit: BoxFit.cover)),
                  Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: Color(0xBF191F28), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                  Positioned(right: 7, bottom: 5, child: AxisTag(video.length, tone: AxisTagTone.dark)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: communityText),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.number, required this.last});

  final PlanStep step;
  final int number;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final top = number == 1 ? 0.0 : 18.0;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 25,
            child: Column(
              children: [
                Container(width: 2, height: top, color: AppColors.gray03),
                AxisTimelineMarker(number: number),
                if (!last) Expanded(child: Container(width: 2, color: AppColors.gray03)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: top, bottom: last ? 0 : 20),
              decoration: BoxDecoration(
                border: last ? null : const Border(bottom: BorderSide(color: AppColors.gray02)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: step.week,
                      children: [
                        TextSpan(
                          text: '  ·  ${step.when}',
                          style: const TextStyle(color: AppColors.gray05),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray07,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(step.title, style: AxisText.rowTitle.copyWith(color: communityText)),
                  const SizedBox(height: 4),
                  Text(step.body, style: AxisText.body.copyWith(color: communityBody)),
                  const SizedBox(height: 4),
                  AxisTag(step.tool, tone: AxisTagTone.neutral),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 하루 루틴 줄 끝 ＋ 버튼(회색 원). 담으면 파란 체크.
class _AddRoutineButton extends StatelessWidget {
  const _AddRoutineButton({required this.added, required this.label, required this.onTap});

  final bool added;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: added ? '$label 빼기' : '$label 추가',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: added ? AppColors.brand : AppColors.gray01, shape: BoxShape.circle),
              child: Icon(
                added ? Icons.check_rounded : Icons.add_rounded,
                size: 20,
                color: added ? Colors.white : AppColors.gray04,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
