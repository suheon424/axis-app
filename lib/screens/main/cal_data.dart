import 'dart:math' as math;

/// 하루를 얼마나 계획대로 보냈는지. 칸 오른쪽 아래 선의 기울기로 보여 준다.
enum CalMark {
  /// 계획대로: 세로선
  plan,

  /// 일부 조정: 사선
  adjust,

  /// 즉흥적으로: 가로선
  free;

  String get label => const ['계획대로', '일부 조정', '즉흥적으로'][index];
}

/// 하루 기록: 진행률(0~1, 칸 색의 진하기)과 일정 수.
class CalDayRecord {
  const CalDayRecord({required this.progress, required this.mark, required this.total, required this.done});

  final double progress;
  final CalMark mark;
  final int total;
  final int done;

  int get percent => (progress * 100).round();
}

/// 캘린더 기록 저장소(메모리). 디자인(2026년 11월, 오늘 23일)을 기준으로 삼는다.
abstract final class CalData {
  /// 디자인 시안의 "오늘". 빨간 점이 찍히는 날이다.
  static final today = DateTime(2026, 11, 23);

  static const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  // 피그마 07_04의 11월 기록(날짜 → 진행률, 선 모양).
  static const _november = <int, (double, CalMark)>{
    1: (0.1, CalMark.free),
    2: (0.2, CalMark.adjust),
    3: (0.3, CalMark.free),
    4: (0.4, CalMark.plan),
    5: (0.5, CalMark.adjust),
    6: (0.6, CalMark.plan),
    7: (0.7, CalMark.plan),
    8: (0.8, CalMark.adjust),
    9: (0.9, CalMark.free),
    10: (1.0, CalMark.adjust),
    12: (1.0, CalMark.adjust),
    14: (0.7, CalMark.plan),
    15: (0.5, CalMark.adjust),
    16: (0.4, CalMark.plan),
    17: (0.2, CalMark.adjust),
    18: (1.0, CalMark.free),
    19: (0.5, CalMark.plan),
    20: (0.8, CalMark.adjust),
    21: (0.2, CalMark.free),
    23: (0.2, CalMark.free),
  };

  static bool isToday(DateTime d) => d.year == today.year && d.month == today.month && d.day == today.day;

  static bool isFuture(DateTime d) => DateTime(d.year, d.month, d.day).isAfter(today);

  /// 그날의 기록. 아직 오지 않은 날이나 기록이 없는 날은 null.
  static CalDayRecord? recordFor(DateTime d) {
    if (isFuture(d)) return null;
    (double, CalMark)? entry;
    if (d.year == 2026 && d.month == 11) {
      entry = _november[d.day];
    } else {
      // 지난달들은 날짜로 정해지는 가짜 기록을 만든다(늘 같은 결과).
      final rnd = math.Random(d.year * 10000 + d.month * 100 + d.day);
      if (rnd.nextInt(100) < 18) return null;
      entry = ((1 + rnd.nextInt(8)) / 10, CalMark.values[rnd.nextInt(3)]);
    }
    if (entry == null) return null;
    final total = d.day.isEven ? 4 : 3;
    return CalDayRecord(progress: entry.$1, mark: entry.$2, total: total, done: (entry.$1 * total).round());
  }

  /// 지난 날들의 평균 진행률(기록 없는 날은 0으로 친다).
  static double monthAverage(DateTime month) {
    final days = calDaysInMonth(month.year, month.month);
    var sum = 0.0;
    var count = 0;
    for (var d = 1; d <= days; d++) {
      final date = DateTime(month.year, month.month, d);
      if (isFuture(date)) break;
      sum += recordFor(date)?.progress ?? 0;
      count++;
    }
    return count == 0 ? 0 : sum / count;
  }

  /// 상단 배너 문구: 지난달과 비교한 달성률.
  static String bannerMessage(DateTime month) {
    final now = monthAverage(month);
    final before = monthAverage(DateTime(month.year, month.month - 1));
    if (before == 0) return '이번 달도 차근차근 실천해 봐요!';
    if (now >= before) return '지난달보다 달성률이 높아요. 잘 실천하고 있어요!';
    return '지난달보다 조금 낮아요. 다시 힘내 볼까요?';
  }

  static String dayTitle(DateTime d) => '${d.month}월 ${d.day}일 (${weekdays[d.weekday % 7]})';
}

/// 그 달의 날 수.
int calDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
