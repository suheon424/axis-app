import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import '../badge/badge_data.dart';
import '../badge/badge_detail_screen.dart';
import '../badge/badge_storage_screen.dart';
import '../badge/badge_widgets.dart';
import 'event_data.dart';
import 'event_widgets.dart';

/// 10-6_이벤트 상세 (배지 컬렉션)(130:12992).
/// 11월 한정 배지 4종의 모음 현황. 칸을 누르면 배지 상세, "배지 모으러 가기"는 배지 보관함(11)으로 간다.
class EventBadgeCollectionScreen extends StatelessWidget {
  const EventBadgeCollectionScreen({super.key});

  static const _medals = [AxisMedal.coordSharer, AxisMedal.shareSprout, AxisMedal.dawnAxis, AxisMedal.focusOrbit];

  @override
  Widget build(BuildContext context) {
    final info = eventCatalog[EventKind.badgeCollection]!;
    final badges = [for (final m in _medals) badgeFor(m)];
    final got = badges.where((b) => b.earned).length;
    return EventDetailScaffold(
      cta: AxisCtaButton(
        label: '배지 모으러 가기',
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BadgeStorageScreen())),
      ),
      children: [
        EventHero(info: info, status: EventStatusStore.of(EventKind.badgeCollection), tag: '참여중', tagBlue: true),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CountTitle('모은 배지', '$got/${badges.length}'),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: got / badges.length,
                  minHeight: 8,
                  color: AppColors.brand,
                  backgroundColor: AppColors.toggleOff,
                ),
              ),
              const SizedBox(height: 30),
              for (var i = 0; i < badges.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 8),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _Tile(badge: badges[i])),
                      const SizedBox(width: 10),
                      Expanded(child: _Tile(badge: badges[i + 1])),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 31),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4종 모두 모으면',
                      style: TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.error),
                    ),
                    Text('‘컬렉터’ 한정 배지 + 2,000P', style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 배지 칸(170×180, 회색 굴곡 8). 획득은 파란 "획득 완료", 잠김은 자물쇠·진행 바.
class _Tile extends StatelessWidget {
  const _Tile({required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: badge.name,
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BadgeDetailScreen(badge: badge))),
      builder: (context, _) => Container(
        constraints: const BoxConstraints(minHeight: 180),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: badge.earned
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AxisMedalImage(badge.medal, size: 74),
                    const SizedBox(height: 8),
                    Text(
                      badge.name,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray07,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('획득 완료', style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.brand)),
                  ],
                )
              : AxisBadgeItem(medal: badge.medal, caption: badge.caption, progress: badge.progress),
        ),
      ),
    );
  }
}
