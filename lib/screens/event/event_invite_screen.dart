import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'event_data.dart';
import 'event_widgets.dart';

/// 10-5_이벤트 상세 (친구 초대)(130:12944).
/// 내 초대 코드(복사), 초대 현황 0/3명, 초대 보상, 유의사항. 아래 "링크 복사 | 카카오톡 초대".
class EventInviteScreen extends StatelessWidget {
  const EventInviteScreen({super.key});

  static const code = 'AXIS-SH24';
  static const link = 'https://axis.app/invite/AXIS-SH24';

  void _copy(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    showAxisToast(context, message, bottom: 100);
  }

  void _kakao(BuildContext context) => showAxisToast(context, '카카오톡으로 초대 메시지를 보냈어요', bottom: 100);

  @override
  Widget build(BuildContext context) {
    final info = eventCatalog[EventKind.invite]!;
    return EventDetailScaffold(
      cta: AxisSplitButton(
        leftLabel: '링크 복사',
        rightLabel: '카카오톡 초대',
        onLeft: () => _copy(context, link, '초대 링크를 복사했어요'),
        onRight: () => _kakao(context),
      ),
      children: [
        EventHero(info: info, status: EventStatusStore.of(EventKind.invite)),
        const SizedBox(height: 40),
        const EventSectionTitle('내 초대 코드'),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              color: AppColors.gray01,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.chipBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(code, style: AxisText.title18.copyWith(color: AppColors.text)),
                ),
                PressBuilder(
                  semanticLabel: '초대 코드 복사',
                  onTap: () => _copy(context, code, '초대 코드를 복사했어요'),
                  builder: (context, pressed) => Container(
                    constraints: const BoxConstraints(minHeight: 26),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                    decoration: BoxDecoration(
                      color: pressed ? AppColors.brandSoft : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray03),
                    ),
                    child: const Text(
                      '복사',
                      style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.brand),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const EventSectionTitle('초대 현황', count: '0/3명'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [for (var i = 1; i <= 3; i++) _Slot(index: i, onTap: () => _kakao(context))],
        ),
        const SizedBox(height: 21),
        const AxisSectionDivider(),
        const SizedBox(height: 24),
        const EventSectionTitle('초대 보상'),
        const SizedBox(height: 9),
        const _RewardRow(count: 1, title: '나와 친구 모두 1,000P', sub: '친구 1명이 가입하고 첫 일정을 완료하면'),
        const _RewardRow(count: 3, title: '스타벅스 아메리카노 추가 증정', sub: '친구 3명 초대를 달성하면'),
        const SizedBox(height: 12),
        const AxisSectionDivider(),
        const EventNotice(lines: ['친구가 초대 코드로 가입하고 첫 일정을 완료하면 지급돼요.', '포인트는 지급일로부터 1년간 사용할 수 있어요.']),
      ],
    );
  }
}

/// 빈 초대 칸: 56px 점선 원 + "N번째 친구".
class _Slot extends StatelessWidget {
  const _Slot({required this.index, required this.onTap});

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$index번째 친구 초대',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CustomPaint(
                painter: _DashedCircle(),
                child: Center(child: Icon(Icons.add, size: 22, color: AppColors.radioBorder)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$index번째 친구',
              style: const TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.gray06),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedCircle extends CustomPainter {
  const _DashedCircle();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 0.75;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFF9FAFB));
    final p = Paint()
      ..color = AppColors.radioBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const n = 28;
    const sweep = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * sweep, sweep * 0.55, false, p);
    }
  }

  @override
  bool shouldRepaint(_DashedCircle old) => false;
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.count, required this.title, required this.sub});

  final int count;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray03, width: 1.5),
            ),
            child: Text(
              '$count명',
              style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.gray06),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 3),
                Text(sub, style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF6B7684))),
              ],
            ),
          ),
          Text('0/$count명', style: AxisText.caption),
        ],
      ),
    );
  }
}
