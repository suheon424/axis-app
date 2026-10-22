import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// J모드에서 일정 옆에 붙는 AI 꼬리표(Pace · Plan B)와 펼치면 보이는 제안.
enum ListTagKind { pace, planB }

class ListTag {
  const ListTag({required this.kind, required this.message, required this.actions});

  final ListTagKind kind;
  final String message;

  /// 첫 번째가 주 행동(색 테두리), 두 번째가 있으면 "괜찮아요" 같은 보조 행동.
  final List<String> actions;

  String get label => kind == ListTagKind.pace ? 'Pace' : 'Plan B';
  Color get color => kind == ListTagKind.pace ? CubeColors.red : CubeColors.green;
  Color get background => kind == ListTagKind.pace ? const Color(0xFFFFF0F0) : const Color(0xFFE9F7F1);

  /// 제안 문구의 그라디언트 끝 색(Pace 빨강→주황, Plan B 초록→파랑).
  Color get gradientEnd => kind == ListTagKind.pace ? CubeColors.orange : CubeColors.blue;
}

/// 일정 목록의 한 줄.
class ListSchedule {
  ListSchedule({
    required this.id,
    required this.title,
    required this.time,
    required this.endTime,
    required this.place,
    required this.address,
    required this.repeat,
    this.done = false,
    this.tag,
  });

  final int id;
  String title;
  String time;
  String endTime;
  final String place;
  final String address;
  final String repeat;
  bool done;
  ListTag? tag;

  String get timeRange => '$time – ${endTime.replaceFirst(RegExp(r'^(AM|PM) '), '')}';
}

/// 07_05 디자인의 23일(월) 일정 6건. 앞의 두 건은 이미 완료.
List<ListSchedule> listSampleSchedules() => [
  ListSchedule(
    id: 1,
    title: '회사 출근',
    time: 'AM 08:30',
    endTime: 'AM 09:00',
    place: '브릿지파트너스',
    address: '서울 마포구 공덕동',
    repeat: '평일마다 반복',
    done: true,
    tag: const ListTag(
      kind: ListTagKind.pace,
      message: '비 소식이 있습니다.\n우산을 챙기고, 10분 일찍 출발하는 건 어떨까요?',
      actions: ['10분 일찍 알림 받기', '괜찮아요'],
    ),
  ),
  ListSchedule(
    id: 2,
    title: '기획안 제출',
    time: 'AM 11:00',
    endTime: 'PM 12:00',
    place: '브릿지파트너스',
    address: '서울 마포구 공덕동',
    repeat: '반복 안 함',
    done: true,
    tag: const ListTag(kind: ListTagKind.planB, message: '회의 전 기획안 마무리하기', actions: ['플랜 B로 바꾸기']),
  ),
  ListSchedule(
    id: 3,
    title: '팀 점심',
    time: 'PM 12:30',
    endTime: 'PM 01:30',
    place: '공덕 소담식당',
    address: '서울 마포구 공덕동',
    repeat: '반복 안 함',
  ),
  ListSchedule(
    id: 4,
    title: '고객사 미팅',
    time: 'PM 03:00',
    endTime: 'PM 04:00',
    place: '한빛테크',
    address: '서울 영등포구 여의도동',
    repeat: '반복 안 함',
  ),
  ListSchedule(
    id: 5,
    title: '러닝 5km',
    time: 'PM 07:30',
    endTime: 'PM 08:15',
    place: '효창공원',
    address: '서울 용산구 효창동',
    repeat: '매주 월·수·금 반복',
  ),
  ListSchedule(
    id: 6,
    title: '관리비 납부',
    time: 'PM 09:00',
    endTime: 'PM 09:10',
    place: '온라인 납부',
    address: '아파트 관리비',
    repeat: '매월 23일 반복',
  ),
];
