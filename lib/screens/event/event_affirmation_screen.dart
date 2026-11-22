import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'event_data.dart';
import 'event_widgets.dart';

/// 10-4_이벤트 상세 (동기부여·긍정확언 · 참여 완료)(130:12883).
/// 참여 완료 안내 띠, 내가 남긴 확언, 메이트들의 확언(공감순, 엄지로 공감).
class EventAffirmationScreen extends StatefulWidget {
  const EventAffirmationScreen({super.key});

  @override
  State<EventAffirmationScreen> createState() => _EventAffirmationScreenState();
}

class _EventAffirmationScreenState extends State<EventAffirmationScreen> {
  static const _items = [
    (1, '작은 완료가 쌓이면 큰 흐름이 된다', 128),
    (2, '어제보다 한 칸만 더 채우면 충분해', 97),
    (0, '계획이 틀어져도 다시 맞추면 된다', 85),
  ];

  final _liked = <int>{};

  @override
  Widget build(BuildContext context) {
    final info = eventCatalog[EventKind.affirmation]!;
    return EventDetailScaffold(
      cta: AxisCtaButton(label: '내 확언 공유하기', onPressed: () => showAxisToast(context, '확언 카드 링크를 복사했어요', bottom: 100)),
      children: [
        EventHero(info: info, status: EventStatusStore.of(EventKind.affirmation), tag: '참여 완료'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: AppColors.gray09, shape: BoxShape.circle),
                  child: const Center(child: AxisIcon(KitIcon.checkWhite, size: 16)),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '참여 완료! 50P가 적립됐어요',
                        style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '11.20 참여 · 포인트 내역에서 확인할 수 있어요',
                        style: TextStyle(fontSize: 12, height: 1.4, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        const EventSectionTitle('내가 남긴 확언'),
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('나는 오늘 계획한 것을 하나씩 해내는 사람이다', style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text('11.20', style: AxisText.caption),
                    Spacer(),
                    Text(
                      '32',
                      style: TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.brand),
                    ),
                    SizedBox(width: 4),
                    AxisIcon(KitIcon.smallLikeOn, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 39),
        const AxisSectionDivider(),
        const SizedBox(height: 40),
        const EventSectionTitle('메이트들의 확언', trailing: EventMeta('공감순')),
        const SizedBox(height: 15),
        for (var i = 0; i < _items.length; i++)
          _AffirmationRow(
            mate: mates[_items[i].$1],
            text: _items[i].$2,
            likes: _items[i].$3 + (_liked.contains(i) ? 1 : 0),
            liked: _liked.contains(i),
            last: i == _items.length - 1,
            onLike: () => setState(() => _liked.contains(i) ? _liked.remove(i) : _liked.add(i)),
          ),
      ],
    );
  }
}

class _AffirmationRow extends StatelessWidget {
  const _AffirmationRow({
    required this.mate,
    required this.text,
    required this.likes,
    required this.liked,
    required this.last,
    required this.onLike,
  });

  final Mate mate;
  final String text;
  final int likes;
  final bool liked;
  final bool last;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: MateAvatar(character: mate.character, color: mate.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 76),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: last ? null : const Border(bottom: BorderSide(color: AppColors.gray02)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mate.name,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.36,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7684),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(text, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    selected: liked,
                    label: '공감 $likes',
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onLike,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 10, 0, 10),
                        child: Row(
                          children: [
                            Text(
                              '$likes',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.36,
                                fontWeight: FontWeight.w500,
                                color: liked ? AppColors.brand : AppColors.gray06,
                              ),
                            ),
                            const SizedBox(width: 7),
                            AxisIcon(liked ? KitIcon.smallLikeOn : KitIcon.smallLikeOff, size: 14),
                          ],
                        ),
                      ),
                    ),
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
