import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'event_data.dart';
import 'event_widgets.dart';

/// 10-3_이벤트 상세 (이달의 계획왕)(130:12805).
/// 순위 보상 3칸, 내 예상 순위, 실시간 순위 1~5위. "참여하기"를 누르면 참여 중으로 바뀌고 목록 배지도 바뀐다.
class EventPlanKingScreen extends StatelessWidget {
  const EventPlanKingScreen({super.key});

  static const _ranks = [(98, 41), (97, 33), (96, 29), (95, 22), (95, 18)];

  void _join(BuildContext context) {
    EventStatusStore.set(EventKind.planKing, AxisEventStatus.joined);
    showAxisToast(context, '계획왕 도전에 참여했어요', bottom: 100);
  }

  @override
  Widget build(BuildContext context) {
    final info = eventCatalog[EventKind.planKing]!;
    return ValueListenableBuilder(
      valueListenable: EventStatusStore.statuses,
      builder: (context, statuses, _) {
        final status = statuses[EventKind.planKing]!;
        final joined = status != AxisEventStatus.join;
        return EventDetailScaffold(
          cta: AxisCtaButton(label: joined ? '참여 중' : '참여하기', enabled: !joined, onPressed: () => _join(context)),
          children: [
            EventHero(info: info, status: status, tag: joined ? '참여 중' : '참여 전', tagBlue: joined),
            const SizedBox(height: 26),
            const EventSectionTitle('혜택'),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Reward(rank: '1위', value: '10,000P', top: true),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _Reward(rank: '2–3위', value: '5,000P'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _Reward(rank: '4–10위', value: '한정 배지'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 29),
            const EventSectionTitle('실시간 순위', trailing: EventMeta('09:00 AM 기준')),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _MyRank(joined: joined),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < mates.length; i++)
              _RankRow(
                rank: i + 1,
                mate: mates[i],
                rate: _ranks[i].$1,
                streak: _ranks[i].$2,
                last: i == mates.length - 1,
              ),
          ],
        );
      },
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward({required this.rank, required this.value, this.top = false});

  final String rank;
  final String value;
  final bool top;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 77),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rank,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: top ? AppColors.brand : const Color(0xFF6B7684),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AxisText.rowTitle.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }
}

class _MyRank extends StatelessWidget {
  const _MyRank({required this.joined});

  final bool joined;

  @override
  Widget build(BuildContext context) {
    const meta = TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.neutralText);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 15, 15, 15),
      decoration: BoxDecoration(
        color: AppColors.gray01,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brand),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('내 예상 순위', style: meta),
              const SizedBox(height: 2),
              Text('128위', style: AxisText.sectionTitle.copyWith(color: AppColors.brand)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('달성률 82% · 상위 12%', style: meta, textAlign: TextAlign.right),
                const SizedBox(height: 5),
                Text(joined ? '순위에 반영되고 있어요' : '참여하면 순위에 반영돼요', textAlign: TextAlign.right, style: AxisText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.mate,
    required this.rate,
    required this.streak,
    required this.last,
  });

  final int rank;
  final Mate mate;
  final int rate;
  final int streak;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                '$rank',
                style: AxisText.rowTitle.copyWith(color: rank <= 3 ? AppColors.brand : AppColors.gray06),
              ),
            ),
          ),
          MateAvatar(character: mate.character, color: mate.color),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: last ? null : const Border(bottom: BorderSide(color: AppColors.gray02)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mate.name, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                        Text('연속 $streak일', style: AxisText.caption),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '달성률 ',
                          style: TextStyle(color: AppColors.gray06),
                        ),
                        TextSpan(
                          text: '$rate%',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                        ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
