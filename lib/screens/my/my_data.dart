import 'package:flutter/foundation.dart';

import '../../widgets/kit/kit.dart';

/// 내 프로필(앱 안 메모리). 내 정보 수정에서 바꾸면 마이 화면이 따라 바뀐다.
class MyProfile {
  const MyProfile({
    required this.nickname,
    required this.callName,
    required this.intro,
    required this.character,
    required this.points,
  });

  final String nickname;

  /// 마이 화면 인사에 쓰는 이름("수현 님").
  final String callName;
  final String intro;

  /// 캐릭터 1~12(AxisAvatar).
  final int character;
  final int points;

  static const email = 'suhyun@axis.app';
  static const loginMethod = '이메일';
  static const joinedAt = '2026.03.14';
  static const appVersion = '11.23.0';

  MyProfile copyWith({String? nickname, String? callName, String? intro, int? character, int? points}) => MyProfile(
    nickname: nickname ?? this.nickname,
    callName: callName ?? this.callName,
    intro: intro ?? this.intro,
    character: character ?? this.character,
    points: points ?? this.points,
  );
}

final myProfile = ValueNotifier(
  const MyProfile(nickname: '황수현', callName: '수현', intro: '계획은 작게, 실행은 꾸준히', character: 5, points: 1550),
);

/// 1,550 → "1,550P"
String formatPoints(int p) {
  final s = p.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${p < 0 ? '-' : ''}$b';
}

/// 포인트 내역 한 줄.
class PointEntry {
  const PointEntry(this.date, this.title, this.source, this.time, this.amount, this.balance);

  /// "2026.11.23 (월)"
  final String date;
  final String title;
  final String source;
  final String time;
  final int amount;
  final int balance;
}

const samplePointEntries = [
  PointEntry('2026.11.23 (월)', '매일 출석', '출석 이벤트', '09:12 AM', 10, 1550),
  PointEntry('2026.11.20 (금)', '14일 출석 보상', '출석 이벤트', '09:03 PM', 300, 1540),
  PointEntry('2026.11.20 (금)', '긍정확언 참여', '동기부여 이벤트', '08:40 AM', 50, 1240),
  PointEntry('2026.11.18 (수)', '테마 ‘새벽 블루’ 구매', '포인트 사용', '10:15 PM', -500, 1190),
  PointEntry('2026.11.13 (금)', '7일 출석 보상', '출석 이벤트', '08:47 PM', 100, 1690),
  PointEntry('2026.11.13 (금)', '매일 출석', '출석 이벤트', '07:58 AM', 10, 1590),
];

/// 내가 쓴 게시물.
class MyPost {
  const MyPost(this.thumb, this.title, this.summary, this.bookmarks, this.meta, this.kind);

  /// 40 정사각 사진(굴곡 8).
  final String thumb;
  final String title;
  final String summary;
  final int bookmarks;

  /// "댓글 24 · 조회 1.2천 · 11.21"
  final String meta;

  /// 필터용 종류(플랜 / 후기)
  final String kind;
}

const sampleMyPosts = [
  MyPost(
    'assets/images/my/post_running.png',
    '한강 러닝 5km 4주 플랜',
    '퇴근 후 30분, 여의도 한강공원 코스',
    128,
    '댓글 24 · 조회 1.2천 · 11.21',
    '플랜',
  ),
  MyPost(
    'assets/images/my/post_exam.png',
    '주말 몰아서 끝내는 정처기 계획',
    '토·일 4시간씩 6주, 기출 위주로 합격까지',
    86,
    '댓글 12 · 조회 904 · 11.08',
    '플랜',
  ),
  MyPost(
    'assets/images/my/post_morning.png',
    '직장인 아침 루틴 30일 플랜',
    '6시 기상부터 출근 전 1시간 쓰는 법',
    342,
    '댓글 57 · 조회 3.4천 · 10.27',
    '후기',
  ),
];

/// 내가 쓴 댓글.
class MyComment {
  const MyComment(this.postTitle, this.date, this.likes, this.body);

  final String postTitle;
  final String date;
  final int likes;
  final String body;
}

const sampleMyComments = [
  MyComment('비전공생의 CPA 공부 계획', '2026.11.22', 3, '1차 끝나고 2차 준비 기간은 어떻게 나누셨어요?\n저도 직장 병행 중이라 궁금해요!'),
  MyComment('-20kg 성공한 다이어트 루틴', '2026.11.19', 12, '아침 루틴 그대로 따라 하는 중인데\n2주 차에 벌써 습관이 됐어요'),
  MyComment('토익스피킹 AL 한 번에 달성', '2026.11.12', 5, '템플릿 적용했어요.\n파트별로 나눠져 있어서 일정 잡기 편하네요'),
  MyComment('비전공생의 CPA 공부 계획', '2026.11.03', 8, '계획 틀어질 때마다 AI로 다시 맞추니까 훨씬 덜 부담돼요'),
];

/// 저장한 템플릿.
class SavedTemplate {
  const SavedTemplate(this.image, this.title, this.description, this.duration, this.footnote);

  final String image;
  final String title;
  final String description;
  final String duration;
  final String footnote;
}

const sampleSavedTemplates = [
  SavedTemplate(
    'assets/images/my/template_1.jpg',
    '비전공생의 CPA 공부 계획',
    '비전공생, 1년 6개월 만에 CPA 초시 동차 합격',
    '3달 소요',
    '댓글 46 · 떡잎부터회계사',
  ),
  SavedTemplate(
    'assets/images/my/template_2.jpg',
    '-20kg 성공한 다이어트 루틴',
    '무리하지 않는 하루 5개 루틴으로 성공!',
    '3달 소요',
    '댓글 99+ · 매력둥이gdken',
  ),
  SavedTemplate(
    'assets/images/my/template_3.jpg',
    '토익스피킹 AL 한 번에 달성',
    '최신 공부법과 파트별 핵심 전략',
    '3달 소요',
    '댓글 99+ · Trend Buff',
  ),
];

/// 공지 종류(태그 색).
enum NoticeKind {
  update('업데이트', AxisTagTone.blue),
  event('이벤트', AxisTagTone.orange),
  notice('공지', AxisTagTone.gray);

  const NoticeKind(this.label, this.tone);

  final String label;
  final AxisTagTone tone;
}

class Notice {
  const Notice(this.kind, this.title, this.date, this.body, {this.isNew = false});

  final NoticeKind kind;
  final String title;
  final String date;
  final String body;
  final bool isNew;
}

const sampleNotices = [
  Notice(
    NoticeKind.update,
    '11.23.0 업데이트 · 틀어진 일정 AI로 다시 맞추기',
    '2026.11.23',
    '일정이 밀리면 AI가 남은 하루를 다시 짜 드려요.\n일정 목록에서 "다시 맞추기"를 눌러 바로 써 보세요.',
    isNew: true,
  ),
  Notice(
    NoticeKind.event,
    '11월 배지 컬렉션 이벤트 당첨자 발표 안내',
    '2026.11.20',
    '11월 배지 컬렉션 이벤트에 참여해 주신 모든 분께 감사드립니다.\n당첨자에게는 앱 알림으로 개별 안내해 드렸어요.',
  ),
  Notice(
    NoticeKind.notice,
    '개인정보 처리방침 개정 안내 (12.01 시행)',
    '2026.11.16',
    '2026년 12월 1일부터 개정된 개인정보 처리방침이 적용됩니다.\n자세한 변경 내용은 버전 정보 > 개인정보 처리방침에서 확인할 수 있어요.',
  ),
  Notice(NoticeKind.update, '지도에서 동선 최적화 기능이 추가됐어요', '2026.11.09', '하루 일정의 장소를 지도에서 보고, 가장 짧은 동선으로 순서를 바꿀 수 있어요.'),
  Notice(
    NoticeKind.notice,
    '11.12 (목) 02:00 – 04:00 AM 서버 점검 안내',
    '2026.11.05',
    '더 안정적인 서비스를 위해 서버 점검을 진행합니다.\n점검 시간에는 앱 이용이 잠시 제한돼요.',
  ),
  Notice(NoticeKind.event, '친구 초대 이벤트가 시작됐어요', '2026.11.01', '친구를 초대하고 함께 계획을 세우면 두 사람 모두 포인트를 받아요.'),
];
