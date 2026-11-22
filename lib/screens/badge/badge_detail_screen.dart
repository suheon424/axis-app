import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'badge_data.dart';
import 'badge_widgets.dart';

/// 11_뱃지보관함_상세보기(130:15481) · (미획득)(130:15510).
/// 획득한 배지는 조건·획득일·상위 비율과 공유하기, 미획득 배지는 진행 현황·이번 주 기록과 일정 보러가기.
class BadgeDetailScreen extends StatelessWidget {
  const BadgeDetailScreen({super.key, required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final b = badge;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AxisBackTitleBar(title: '배지 상세'),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  children: [
                    _Hero(badge: b),
                    const SizedBox(height: 38),
                    Row(
                      children: [
                        Flexible(
                          child: Text(b.name, style: AxisText.sectionTitle.copyWith(color: Colors.black)),
                        ),
                        if (!b.earned) ...[const SizedBox(width: 14), const AxisTag('미획득', tone: AxisTagTone.gray)],
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      title: '획득 조건',
                      caption: b.condition,
                      tag: InfoTag(b.earned ? '달성' : '진행 중', blue: !b.earned),
                    ),
                    if (b.earned) ...[
                      _InfoRow(title: '획득일', caption: b.earnedOn!),
                      _InfoRow(title: '함께 획득한 메이트', caption: '전체 메이트 기준', tag: InfoTag('상위 ${b.topPercent}%')),
                    ] else
                      _InfoRow(title: '진행 현황', caption: b.remainingLabel, tag: InfoTag(b.progressLabel)),
                    if (b.week != null) ...[const SizedBox(height: 28), _WeekRecord(marks: b.week!)],
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomCtaBar(
          child: b.earned
              ? AxisCtaButton(label: '공유하기', onPressed: () => showAxisToast(context, '배지 카드 링크를 복사했어요'))
              : AxisCtaButton(label: '일정 보러가기', onPressed: () => MainTabRouter.open(context, MainTab.home)),
        ),
      ),
    );
  }
}

/// 350×200 배지 무대: 획득은 하늘색, 미획득은 회색 빛 + 왼쪽 위 자물쇠. 아래 흐린 그림자 타원.
class _Hero extends StatelessWidget {
  const _Hero({required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;
    return Container(
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: earned
            ? const RadialGradient(
                center: Alignment(1, -1),
                radius: 1.6,
                colors: [Color(0xFF71C3FF), Color(0xFFB9E1FF), Color(0xFFEFF7FF)],
                stops: [0, 0.45, 1],
              )
            : const RadialGradient(
                center: Alignment(1, -1),
                radius: 1.6,
                colors: [Color(0xFFC3C6CF), Color(0xFFDDDFE5), Color(0xFFF4F5FA)],
                stops: [0, 0.45, 1],
              ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 6,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Transform.scale(
                scaleX: 204 / 29,
                child: Container(
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (earned ? const Color(0xFF1B598C) : const Color(0xFF808184)).withValues(alpha: 0.5),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(top: 40, child: AxisMedalImage(badge.medal, size: 120)),
          if (!earned) const Positioned(left: 10, top: 10, child: LockDot(size: 28)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.caption, this.tag});

  final String title;
  final String caption;
  final Widget? tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray02)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AxisText.rowTitle),
                const SizedBox(height: 2),
                Text(caption, style: AxisText.caption),
              ],
            ),
          ),
          if (tag != null) ...[const SizedBox(width: 12), tag!],
        ],
      ),
    );
  }
}

/// 이번 주 기록: 월~토 동그라미(파란 체크 / 회색 빠짐) + 오늘(파란 점선 고리).
class _WeekRecord extends StatelessWidget {
  const _WeekRecord({required this.marks});

  final List<BadgeDayMark> marks;

  static const _labels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 15, 22, 16),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번 주 기록',
            style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < marks.length; i++)
                Column(
                  children: [
                    _DayDot(mark: marks[i]),
                    const SizedBox(height: 4),
                    Text(
                      marks[i] == BadgeDayMark.today ? '오늘' : _labels[i],
                      style: marks[i] == BadgeDayMark.today
                          ? const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brand,
                            )
                          : const TextStyle(
                              fontSize: 12,
                              height: 1.36,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray06,
                            ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.mark});

  final BadgeDayMark mark;

  @override
  Widget build(BuildContext context) {
    return switch (mark) {
      BadgeDayMark.done => Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
        child: const Center(child: AxisIcon(KitIcon.checkWhite, size: 18)),
      ),
      BadgeDayMark.missed => Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: Color(0xFFE5E8EB), shape: BoxShape.circle),
        child: Center(
          child: Container(
            width: 10,
            height: 2,
            decoration: BoxDecoration(color: AppColors.radioBorder, borderRadius: BorderRadius.circular(1)),
          ),
        ),
      ),
      BadgeDayMark.today => const SizedBox(width: 30, height: 30, child: CustomPaint(painter: _DashedRing())),
    };
  }
}

class _DashedRing extends CustomPainter {
  const _DashedRing();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 0.75;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    final paint = Paint()
      ..color = AppColors.brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dashes = 14;
    const sweep = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * sweep, sweep * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => false;
}
