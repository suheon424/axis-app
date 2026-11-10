import 'package:flutter/foundation.dart';

import '../../widgets/kit/kit.dart';

/// 이벤트 탭의 이벤트 종류. 10_이벤트의 배너·목록과 10-1~10-6 상세가 이 값으로 이어진다.
enum EventKind { cube, attendance, planKing, affirmation, invite, badgeCollection }

/// 이벤트 하나의 고정 정보.
class EventInfo {
  const EventInfo({
    required this.kind,
    required this.listTitle,
    required this.heroTitle,
    required this.bannerTitle,
    required this.bannerCaption,
    required this.period,
    required this.daysLeft,
    this.icon,
  });

  final EventKind kind;

  /// 10_이벤트 목록 줄 제목(배너 전용 이벤트는 null 대신 빈 문자열).
  final String listTitle;

  /// 상세 화면 위 연파랑 카드의 제목(줄바꿈 포함).
  final String heroTitle;

  /// 10_이벤트 큐브 배너의 큰 제목·작은 설명.
  final String bannerTitle;
  final String bannerCaption;
  final String period;
  final int daysLeft;

  /// 3D 메탈 아이콘. null이면 큐브 그림(assets/images/event/event_cube.png).
  final AxisEventIconType? icon;

  String get daysLeftLabel => '$daysLeft일 남음';
}

/// Banner/Event(205:10599) 변형별 그림: 파일, 배너(292) 안 위치, 너비.
class EventBannerArt {
  const EventBannerArt(this.asset, this.left, this.top, this.width);

  final String asset;
  final double left;
  final double top;
  final double width;
}

const eventBannerArt = <EventKind, EventBannerArt>{
  EventKind.cube: EventBannerArt('assets/images/event/banner_cube.png', 147, 9, 135),
  EventKind.attendance: EventBannerArt('assets/images/event/banner_attendance.png', 148, 9, 144),
  EventKind.planKing: EventBannerArt('assets/images/event/banner_plan_king.png', 141, -1, 131),
  EventKind.affirmation: EventBannerArt('assets/images/event/banner_affirmation.png', 147, 9, 135),
  EventKind.invite: EventBannerArt('assets/images/event/banner_invite.png', 147, -1, 135),
  EventKind.badgeCollection: EventBannerArt('assets/images/event/banner_badge.png', 166, 12, 110),
};

const eventCatalog = <EventKind, EventInfo>{
  EventKind.cube: EventInfo(
    kind: EventKind.cube,
    listTitle: '',
    heroTitle: '내가 만든 큐브를\n자랑해주세요!',
    bannerTitle: '내가 만든 \n큐브를\n자랑해주세요!',
    bannerCaption: '매월 5명 선정\n스타벅스 아메리카노(R) 증정',
    period: '11.01 – 11.30',
    daysLeft: 7,
  ),
  EventKind.attendance: EventInfo(
    kind: EventKind.attendance,
    listTitle: '매일 출석하고 포인트와 선물 받아요',
    heroTitle: '매일 출석하고\n포인트&선물 받자!',
    bannerTitle: '매일 \n출석하고\n포인트&선물 받자!',
    bannerCaption: '25일 출석하면\n1,000P + 한정 배지',
    period: '11.07 – 12.06',
    daysLeft: 13,
    icon: AxisEventIconType.attendance,
  ),
  EventKind.planKing: EventInfo(
    kind: EventKind.planKing,
    listTitle: '이달의 계획왕에 도전해 보세요!',
    heroTitle: '이달의 계획왕에\n도전해 보세요!',
    bannerTitle: '이달의\n계획왕에\n도전해 보세요!',
    bannerCaption: '1위 10,000P\n4–10위 한정 배지',
    period: '11.14 – 12.13',
    daysLeft: 20,
    icon: AxisEventIconType.planKing,
  ),
  EventKind.affirmation: EventInfo(
    kind: EventKind.affirmation,
    listTitle: '긍정 확언 남기기',
    heroTitle: '동기부여/긍정확언\n이벤트',
    bannerTitle: '오늘의\n긍정 확언을\n남겨 보세요',
    bannerCaption: '참여하면 50P 적립\n메이트와 공감 나누기',
    period: '11.17 – 11.29',
    daysLeft: 6,
    icon: AxisEventIconType.affirmation,
  ),
  EventKind.invite: EventInfo(
    kind: EventKind.invite,
    listTitle: '친구 초대 이벤트',
    heroTitle: '친구 초대하면\n둘 다 1,000P!',
    bannerTitle: '친구  초대하면\n둘 다 1,000P!',
    bannerCaption: '3명 초대하면\n스타벅스 아메리카노 추가',
    period: '11.01 – 11.27',
    daysLeft: 4,
    icon: AxisEventIconType.invite,
  ),
  EventKind.badgeCollection: EventInfo(
    kind: EventKind.badgeCollection,
    listTitle: '배지 컬렉션',
    heroTitle: '11월 한정 배지\n4종을 모아보세요',
    bannerTitle: '11월 한정\n배지 4종을\n모아 보세요',
    bannerCaption: '4종 모두 모으면\n‘컬렉터’ 배지 + 2,000P',
    period: '11.01 – 11.27',
    daysLeft: 4,
    icon: AxisEventIconType.badge,
  ),
};

/// 10_이벤트 목록 순서(큐브 자랑은 배너에만 있다).
const eventListOrder = [
  EventKind.attendance,
  EventKind.planKing,
  EventKind.affirmation,
  EventKind.invite,
  EventKind.badgeCollection,
];

/// 이벤트마다 내 참여 상태. 상세에서 참여하면 목록 배지도 함께 바뀐다(앱 실행 중에만 유지).
abstract final class EventStatusStore {
  static const _initial = {
    EventKind.cube: AxisEventStatus.joined,
    EventKind.attendance: AxisEventStatus.joined,
    EventKind.planKing: AxisEventStatus.join,
    EventKind.affirmation: AxisEventStatus.done,
    EventKind.invite: AxisEventStatus.joined,
    EventKind.badgeCollection: AxisEventStatus.joined,
  };

  static final statuses = ValueNotifier<Map<EventKind, AxisEventStatus>>(Map.of(_initial));

  static AxisEventStatus of(EventKind kind) => statuses.value[kind]!;

  static void set(EventKind kind, AxisEventStatus status) {
    statuses.value = {...statuses.value, kind: status};
  }

  /// 테스트용: 처음 상태로 되돌린다.
  @visibleForTesting
  static void reset() => statuses.value = Map.of(_initial);
}
