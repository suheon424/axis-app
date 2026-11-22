import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'event_data.dart';
import 'event_widgets.dart';

enum _Day { done, reward, absent, today, future, upcomingReward }

/// 10-1_이벤트 상세 (매일 출석)(130:14067).
/// 이번 달 출석판(30칸)과 출석 보상 단계. "오늘 출석하기"를 누르면 오늘 칸이 채워지고 버튼이 회색이 된다.
class EventAttendanceScreen extends StatefulWidget {
  const EventAttendanceScreen({super.key});

  @override
  State<EventAttendanceScreen> createState() => _EventAttendanceScreenState();
}

class _EventAttendanceScreenState extends State<EventAttendanceScreen> {
  static const _today = 17;
  static const _rewards = {7: '100P', 14: '300P', 21: '커피', 25: '1,000P'};
  bool _checkedIn = false;

  _Day _stateOf(int day) {
    if (day == 11) return _Day.absent;
    if (day == 19) return _Day.future;
    if (day == 18 || day == 20) return _Day.done;
    if (day == _today) return _checkedIn ? _Day.done : _Day.today;
    if (day < _today) return _rewards.containsKey(day) ? _Day.reward : _Day.done;
    return _rewards.containsKey(day) ? _Day.upcomingReward : _Day.future;
  }

  void _checkIn() {
    setState(() => _checkedIn = true);
    showAxisToast(context, '출석 완료! 내일도 한 칸 채워요', bottom: 100);
  }

  @override
  Widget build(BuildContext context) {
    final info = eventCatalog[EventKind.attendance]!;
    final count = 15 + (_checkedIn ? 1 : 0);
    return EventDetailScaffold(
      cta: AxisCtaButton(label: _checkedIn ? '오늘 출석 완료' : '오늘 출석하기', enabled: !_checkedIn, onPressed: _checkIn),
      children: [
        EventHero(info: info, status: EventStatusStore.of(EventKind.attendance)),
        const SizedBox(height: 30),
        const EventSectionTitle('내 출석 현황'),
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.only(top: 16, bottom: 18),
            decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _Stat(label: '출석', value: '$count일'),
                  _Stat(label: '연속', value: '${5 + (_checkedIn ? 1 : 0)}일'),
                  _Stat(label: '다음 보상까지', value: '${21 - count}일', last: true),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (var row = 0; row < 5; row++) ...[
                if (row > 0) const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var d = row * 6 + 1; d <= row * 6 + 6; d++)
                      _DayCell(day: d, state: _stateOf(d), label: d == _today ? '오늘' : _rewards[d]),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 30),
        const AxisSectionDivider(),
        const SizedBox(height: 26),
        const EventSectionTitle('출석 보상'),
        const SizedBox(height: 11),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Positioned(left: 17, top: 38, bottom: 36, child: Container(width: 2, color: AppColors.gray03)),
              Column(
                children: [
                  const _RewardRow(day: 7, title: '7일 출석', sub: '100P 적립', state: _RewardState.done),
                  const _RewardRow(day: 14, title: '14일 출석', sub: '300P 적립', state: _RewardState.done),
                  _RewardRow(
                    day: 21,
                    title: '21일 출석',
                    sub: '스타벅스 아메리카노',
                    state: _RewardState.next,
                    right: '${21 - count}일 남음',
                  ),
                  _RewardRow(
                    day: 25,
                    title: '25일 출석',
                    sub: '1,000P + 한정 배지',
                    state: _RewardState.later,
                    right: '${25 - count}일 남음',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const AxisSectionDivider(),
        const EventNotice(lines: ['출석은 하루 1회, 자정(12:00 AM) 기준으로 초기화돼요.', '기프티콘은 달성 후 7일 이내 쿠폰함으로 발송돼요.']),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: last ? null : const Border(right: BorderSide(color: AppColors.gray03)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray07)),
            const SizedBox(height: 2),
            Text(value, style: AxisText.title18.copyWith(color: AppColors.gray07)),
          ],
        ),
      ),
    );
  }
}

/// 출석판 한 칸(50×50, 굴곡 5.66).
class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.state, this.label});

  final int day;
  final _Day state;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (fill, border, numColor, labelColor) = switch (state) {
      _Day.done => (Colors.white, AppColors.brand, Colors.white, Colors.white),
      _Day.reward => (AppColors.brand, AppColors.brand, Colors.white, AppColors.blue01),
      _Day.absent => (AppColors.gray03, null, AppColors.gray06, AppColors.gray06),
      _Day.today => (Colors.white, AppColors.brand, AppColors.brand, AppColors.brand),
      _Day.future => (Colors.white, AppColors.gray02, AppColors.gray06, AppColors.gray06),
      _Day.upcomingReward => (AppColors.blue01, null, AppColors.gray06, AppColors.brand),
    };
    final text = state == _Day.absent ? '결석' : label;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 50,
      height: 50,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(5.66)),
      // 테두리는 위에 덧그려서(피그마 INSIDE 선) 테두리 없는 칸과 날짜 위치가 같게 한다.
      foregroundDecoration: border == null
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(5.66),
              border: Border.all(color: border, width: 0.94),
            ),
      child: Stack(
        children: [
          if (state == _Day.done) ...[
            const Positioned.fill(child: CustomPaint(painter: _DoneSlash())),
            const Positioned(right: 1, top: 22, child: Icon(Icons.check_rounded, size: 22, color: Color(0xFFB4C4E8))),
          ],
          Positioned(left: 5, top: 2, child: Text('$day', style: _cellText(numColor))),
          if (text != null && state != _Day.done)
            Positioned(right: 5, bottom: 4, child: Text(text, style: _cellText(labelColor))),
        ],
      ),
    );
  }

  static TextStyle _cellText(Color c) => TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: c);
}

/// 출석한 칸의 파란 사선 조각(왼쪽 위 → 오른쪽 아래 가장자리 일부를 남긴다).
class _DoneSlash extends CustomPainter {
  const _DoneSlash();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.9, 0)
      ..lineTo(w * 0.2, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.brand);
  }

  @override
  bool shouldRepaint(_DoneSlash old) => false;
}

enum _RewardState { done, next, later }

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.day, required this.title, required this.sub, required this.state, this.right});

  final int day;
  final String title;
  final String sub;
  final _RewardState state;
  final String? right;

  @override
  Widget build(BuildContext context) {
    final marker = switch (state) {
      _RewardState.done => AxisTimelineMarker(number: day, state: AxisMarkerState.done),
      _RewardState.next => AxisTimelineMarker(number: day, state: AxisMarkerState.current),
      _RewardState.later => Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: AppColors.gray03, shape: BoxShape.circle),
        child: Text(
          '$day',
          style: const TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.w600, color: AppColors.gray07),
        ),
      ),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 73),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const SizedBox(width: 6),
          marker,
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 1),
                Text(sub, style: AxisText.caption),
              ],
            ),
          ),
          Text(
            state == _RewardState.done ? '받음' : right!,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: state == _RewardState.next ? FontWeight.w600 : FontWeight.w500,
              color: state == _RewardState.next ? AppColors.brand : AppColors.gray06,
            ),
          ),
        ],
      ),
    );
  }
}
