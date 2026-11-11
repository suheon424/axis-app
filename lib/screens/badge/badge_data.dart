import '../../widgets/kit/kit.dart';

/// 이번 주 기록 칸 하나의 상태(11_뱃지보관함_상세보기(미획득)).
enum BadgeDayMark { done, missed, today }

/// 배지 보관함에 보이는 배지 한 개. [progress]가 null이면 획득한 배지.
class BadgeInfo {
  const BadgeInfo({
    required this.medal,
    required this.caption,
    required this.condition,
    this.earnedOn,
    this.topPercent,
    this.current,
    this.total,
    this.unit = '',
    this.week,
  });

  final AxisMedal medal;

  /// 보관함 칸 아래 한 줄(획득: 조건 요약, 미획득: "5/7일").
  final String caption;

  /// 상세의 "획득 조건" 설명.
  final String condition;
  final String? earnedOn;
  final int? topPercent;
  final int? current;
  final int? total;
  final String unit;

  /// 월~오늘까지 이번 주 기록(일 단위 배지만).
  final List<BadgeDayMark>? week;

  bool get earned => current == null;
  String get name => medal.title;
  double? get progress => earned ? null : current! / total!;
  String get progressLabel => '$current / $total$unit';
  String get remainingLabel => '${total! - current!}$unit만 더 하면 획득해요';
}

const _d = BadgeDayMark.done, _m = BadgeDayMark.missed, _t = BadgeDayMark.today;

/// 데모용 배지 목록(획득 6 · 미획득 3).
const badgeCatalog = <BadgeInfo>[
  BadgeInfo(
    medal: AxisMedal.awakening,
    caption: '일정 7회 완료',
    condition: '일정 7회 완료',
    earnedOn: '2026.11.20',
    topPercent: 23,
  ),
  BadgeInfo(
    medal: AxisMedal.primeAxis,
    caption: '달성률 90% 달성',
    condition: '한 달 달성률 90% 이상',
    earnedOn: '2026.11.12',
    topPercent: 8,
  ),
  BadgeInfo(
    medal: AxisMedal.flowCenter,
    caption: 'AI로 계획 3회 수정',
    condition: 'AI로 틀어진 계획 3회 수정',
    earnedOn: '2026.11.09',
    topPercent: 31,
  ),
  BadgeInfo(
    medal: AxisMedal.firstStep,
    caption: '7일 이상 출석',
    condition: '이벤트 출석 7일 이상',
    earnedOn: '2026.11.07',
    topPercent: 45,
  ),
  BadgeInfo(
    medal: AxisMedal.coordSharer,
    caption: '친구 초대 10회',
    condition: '친구 초대 10회',
    earnedOn: '2026.11.05',
    topPercent: 12,
  ),
  BadgeInfo(
    medal: AxisMedal.shareSprout,
    caption: '플랜 공유 10회',
    condition: '플랜 공유 10회',
    earnedOn: '2026.11.03',
    topPercent: 17,
  ),
  BadgeInfo(
    medal: AxisMedal.dawnAxis,
    caption: '5/7일',
    condition: '7일 동안 오전 9시 전에 그날 계획 완료',
    current: 5,
    total: 7,
    unit: '일',
    week: [_d, _d, _m, _d, _d, _d, _t],
  ),
  BadgeInfo(
    medal: AxisMedal.focusOrbit,
    caption: '18/30회',
    condition: '집중 모드로 일정 30회 완료',
    current: 18,
    total: 30,
    unit: '회',
  ),
  BadgeInfo(
    medal: AxisMedal.perfectWeek,
    caption: '3/7일',
    condition: '7일 연속 달성률 100%',
    current: 3,
    total: 7,
    unit: '일',
    week: [_m, _m, _m, _d, _d, _d, _t],
  ),
];

BadgeInfo badgeFor(AxisMedal medal) => badgeCatalog.firstWhere((b) => b.medal == medal);
