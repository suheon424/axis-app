import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'event_data.dart';
import 'event_widgets.dart';

/// 10-2_이벤트 상세 (큐브 자랑 · 배너)(130:12757). 10_이벤트의 첫 배너에서 연다.
/// 기간·발표·혜택, 참여 방법 3단계, 참여한 메이트의 큐브. "참여하기"는 탐색(커뮤니티) 탭으로 안내한다.
class EventCubeScreen extends StatelessWidget {
  const EventCubeScreen({super.key});

  static const _steps = [
    ('이번 주 큐브를 완성해요', '일정 6개를 모두 끝내면 큐브 한 면이 완성돼요'),
    ('커뮤니티에 공유해요', '#큐브자랑 태그를 붙여 내 큐브를 올려주세요'),
    ('추첨 결과를 기다려요', '매월 5명을 뽑아 알림으로 알려드려요'),
  ];

  static const _entries = [
    ('떡잎부터회계사', Color(0xFFEAF2FF)),
    ('매력둥이gdken', Color(0xFFFFF4E6)),
    ('Trend Buff', Color(0xFFF2F4F6)),
  ];

  @override
  Widget build(BuildContext context) {
    final info = eventCatalog[EventKind.cube]!;
    return EventDetailScaffold(
      cta: AxisCtaButton(
        label: '참여하기',
        onPressed: () => showAxisToast(
          context,
          '#큐브자랑 태그로 내 큐브를 올려 주세요',
          actionLabel: '탐색',
          onAction: () => MainTabRouter.open(context, MainTab.explore),
          bottom: 100,
        ),
      ),
      children: [
        EventHero(info: info, status: EventStatusStore.of(EventKind.cube), tag: 'D-${info.daysLeft}', tagBlue: true),
        const SizedBox(height: 26),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _InfoLine('기간', '11.01 – 11.30'),
              _InfoLine('발표', '12.05 (금) 알림으로 안내'),
              _InfoLine('혜택', '매월 5명 · 스타벅스 아메리카노'),
            ],
          ),
        ),
        const SizedBox(height: 11),
        const AxisSectionDivider(),
        const SizedBox(height: 30),
        const EventSectionTitle('참여 방법'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Positioned(left: 11.5, top: 20, bottom: 30, child: Container(width: 2, color: AppColors.gray03)),
              Column(
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: AxisTimelineMarker(number: i + 1),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_steps[i].$1, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                                const SizedBox(height: 1),
                                Text(
                                  _steps[i].$2,
                                  style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF6B7684)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const AxisSectionDivider(),
        const SizedBox(height: 34),
        EventSectionTitle(
          '참여한 메이트',
          count: '1,284명',
          trailing: GestureDetector(
            onTap: () => MainTabRouter.open(context, MainTab.explore),
            child: const Row(
              children: [
                EventMeta('전체보기'),
                SizedBox(width: 2),
                AxisChevronRight(size: 20, color: AppColors.gray05),
              ],
            ),
          ),
        ),
        const SizedBox(height: 11),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _entries.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _Entry(name: _entries[i].$1, color: _entries[i].$2),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Text(label, style: style.copyWith(color: AppColors.gray06)),
          ),
          Expanded(
            child: Text(value, style: style.copyWith(color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
            child: Image.asset('assets/images/event/event_cube.png', semanticLabel: '$name의 큐브'),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.neutralText),
        ),
      ],
    );
  }
}
