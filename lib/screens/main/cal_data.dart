import 'dart:math' as math;

import '../../widgets/kit/calendar.dart';

/// 하루 기록: 칸 상태와 일정 수.
class CalDayRecord {
  const CalDayRecord({required this.state, required this.total, required this.done});

  final AxisDayState state;
  final int total;
  final int done;
}

/// 날짜 칸 상태의 이름과 설명(코치마크 범례, 길게 누르기 미리보기).
extension CalDayStateText on AxisDayState {
  String get label => switch (this) {
    AxisDayState.inProgress => '진행 중',
    AxisDayState.done => '완료',
    AxisDayState.scheduled => '시작 전',
    AxisDayState.empty => '일정 없음',
    AxisDayState.today => '오늘',
  };

  String get description => switch (this) {
    AxisDayState.inProgress => '일정을 일부 실천했어요',
    AxisDayState.done => '일정을 모두 실천했어요',
    AxisDayState.scheduled => '아직 실천하지 않았어요',
    AxisDayState.empty => '등록된 일정이 없어요',
    AxisDayState.today => '오늘 날짜를 표시하는 색상이에요',
  };
}

/// 캘린더 기록 저장소(메모리). 디자인(2026년 11월, 오늘 24일)을 기준으로 삼는다.
abstract final class CalData {
  /// 디자인 시안의 "오늘".
  static final today = DateTime(2026, 11, 24);

  static const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  // 피그마 07_04의 11월 칸 상태(적히지 않은 날은 일정 없음).
  static const _november = <int, AxisDayState>{
    1: AxisDayState.done,
    2: AxisDayState.inProgress,
    3: AxisDayState.done,
    4: AxisDayState.scheduled,
    5: AxisDayState.inProgress,
    6: AxisDayState.done,
    7: AxisDayState.scheduled,
    8: AxisDayState.inProgress,
    9: AxisDayState.done,
    10: AxisDayState.scheduled,
    12: AxisDayState.done,
    14: AxisDayState.scheduled,
    15: AxisDayState.scheduled,
    23: AxisDayState.inProgress,
    24: AxisDayState.today,
    26: AxisDayState.inProgress,
    27: AxisDayState.inProgress,
    28: AxisDayState.done,
    29: AxisDayState.done,
  };

  static bool isToday(DateTime d) => d.year == today.year && d.month == today.month && d.day == today.day;

  static bool isFuture(DateTime d) => DateTime(d.year, d.month, d.day).isAfter(today);

  /// 그날 칸의 상태.
  static AxisDayState stateFor(DateTime d) {
    if (d.year == today.year && d.month == today.month) return _november[d.day] ?? AxisDayState.empty;
    if (isFuture(d)) return AxisDayState.empty;
    // 지난달들은 날짜로 정해지는 가짜 기록을 만든다(늘 같은 결과).
    final n = math.Random(d.year * 10000 + d.month * 100 + d.day).nextInt(100);
    if (n < 70) return AxisDayState.empty;
    if (n < 95) return AxisDayState.inProgress;
    return AxisDayState.done;
  }

  /// 그날의 기록. 일정이 없는 날은 null.
  static CalDayRecord? recordFor(DateTime d) {
    final state = stateFor(d);
    final total = d.day.isEven ? 4 : 3;
    return switch (state) {
      AxisDayState.done => CalDayRecord(state: state, total: total, done: total),
      AxisDayState.inProgress => CalDayRecord(state: state, total: total, done: total ~/ 2),
      AxisDayState.scheduled => CalDayRecord(state: state, total: total, done: 0),
      AxisDayState.empty || AxisDayState.today => null,
    };
  }

  /// 오늘까지 날들의 실천 점수 평균(완료 1, 진행 중 0.5).
  static double monthAverage(DateTime month) {
    final days = calDaysInMonth(month.year, month.month);
    var sum = 0.0;
    var count = 0;
    for (var d = 1; d <= days; d++) {
      final date = DateTime(month.year, month.month, d);
      if (isFuture(date)) break;
      sum += switch (stateFor(date)) {
        AxisDayState.done => 1,
        AxisDayState.inProgress => 0.5,
        _ => 0,
      };
      count++;
    }
    return count == 0 ? 0 : sum / count;
  }

  /// 상단 인사 띠 문구: 지난달과 비교한 달성률.
  static String bannerMessage(DateTime month) {
    final now = monthAverage(month);
    final before = monthAverage(DateTime(month.year, month.month - 1));
    if (before == 0) return '이번 달도 차근차근 실천해 봐요!';
    if (now >= before) return '달성률이 높아졌어요. 잘하고 있어요!';
    return '지난달보다 조금 낮아요. 다시 힘내 볼까요?';
  }

  static String dayTitle(DateTime d) => '${d.month}월 ${d.day}일 (${weekdays[d.weekday % 7]})';
}

/// 그 달의 날 수.
int calDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
