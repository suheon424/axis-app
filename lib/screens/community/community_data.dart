import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

const _img = 'assets/images/community';

/// 커뮤니티 사람(작성자·후기·댓글). 캐릭터(1~12)를 [color] 원 안에 그린다.
class CommunityUser {
  const CommunityUser(this.name, this.character, this.color);

  final String name;
  final int character;
  final Color color;
}

const author = CommunityUser('회계하는 고양이', 8, CubeColors.orange);
const _potato = CommunityUser('합격한 감자', 8, CubeColors.yellow);
const _afterWork = CommunityUser('퇴근 후 회계사', 10, CubeColors.orange);
const _noBase = CommunityUser('노베이스탈출', 2, CubeColors.green);

/// 인기 계획 템플릿(09 TOP10 목록 한 줄).
class CommunityTemplate {
  const CommunityTemplate({
    required this.rank,
    required this.title,
    required this.description,
    required this.duration,
    required this.footnote,
    required this.thumb,
    required this.category,
    this.cover,
  });

  final int rank;
  final String title;
  final String description;
  final String duration;
  final String footnote;
  final String thumb;
  final String category;
  final String? cover;
}

const communityTemplates = [
  CommunityTemplate(
    rank: 1,
    title: '비전공생의 CPA 공부 계획',
    description: '비전공생, 1년 6개월 만에 CPA 초시 동차 합격',
    duration: '1달 소요',
    footnote: '댓글 46 · 떡잎부터회계사',
    thumb: '$_img/thumb1.png',
    cover: '$_img/cover.png',
    category: '공부 · 자격증',
  ),
  CommunityTemplate(
    rank: 2,
    title: '-20kg 성공한 다이어트 루틴',
    description: '무리하지 않는 하루 5개 루틴으로 성공!',
    duration: '3달 소요',
    footnote: '댓글 99+ · 매력둥이gdken',
    thumb: '$_img/thumb2.png',
    category: '건강 · 다이어트',
  ),
  CommunityTemplate(
    rank: 3,
    title: '토익스피킹 AL 한 번에 달성',
    description: '최신 공부법과 파트별 핵심 전략',
    duration: '3달 소요',
    footnote: '댓글 99+ · Trend Buff',
    thumb: '$_img/thumb3.png',
    category: '공부 · 어학',
  ),
];

/// 09-5 전체 템플릿: TOP10 다음 순위까지 이어지는 목록.
const allCommunityTemplates = [
  ...communityTemplates,
  CommunityTemplate(
    rank: 4,
    title: '공무원 9급 1년 합격 로드맵',
    description: '하루 6시간, 과목별 회독 순서까지 정리',
    duration: '12달 소요',
    footnote: '댓글 58 · 합격의정석',
    thumb: '$_img/thumb4.png',
    category: '공부 · 공무원',
  ),
  CommunityTemplate(
    rank: 5,
    title: '하루 3시간 수능 영어 루틴',
    description: '단어 · 듣기 · 독해를 3블록으로 나눠요',
    duration: '3달 소요',
    footnote: '댓글 27 · 영어쌤민지',
    thumb: '$_img/thumb5.png',
    category: '공부 · 어학',
  ),
];

/// 09-5 전체 템플릿 수(데모).
const allCommunityTemplateCount = 128;

/// 09 위쪽 "메이트들의 생생 후기" 카드. [template]은 눌렀을 때 여는 템플릿 순번(0부터).
class ReviewHighlight {
  const ReviewHighlight(this.title, this.body, this.rating, this.author, this.template);

  final String title;
  final String body;
  final double rating;
  final String author;
  final int template;
}

const reviewHighlights = [
  ReviewHighlight('무작정 굶는\n다이어트 탈출!', '굶다가 폭식해서 요요 등장..\n신세계를 맛보고 있음', 4.5, '노베이스탈출', 1),
  ReviewHighlight('비전공자 합격 수기\n템플릿 감동이네요ㅠ', '수험 기간 줄이고\n싶은 분들께 강추해요!', 4.7, '기출러', 0),
  ReviewHighlight('토스 AL 진짜\n한 번에 됐어요', '파트별 전략대로만\n연습했더니 AL!', 4.8, '스피킹장인', 2),
  ReviewHighlight('퇴근 후 6시간\n버전도 충분해요', '하루 루틴만 줄여서\n그대로 따라했어요', 4.6, '퇴근 후 회계사', 0),
];

/// 계획서 탭 내용(0901). 피그마에는 CPA 계획서만 있어 모든 템플릿이 같은 내용을 쓴다.
class PlanStat {
  const PlanStat(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;
  final bool highlight;
}

const planStats = [PlanStat('기간', '1달'), PlanStat('하루', '10시간'), PlanStat('북마크', '1,284')];
const planIntro = '비전공생, 1년 6개월 만에 CPA 초시 동차 합격.\n1차 시험 D-30, 마지막 한 달을 이렇게 보냈어요.';
const planAudience = ['비전공 수험생', '1차 D-30', '회독 루틴이 필요한 분'];

/// 준비물. 앞의 3개만 먼저 보이고 "모두 보기"로 펼친다.
const planSupplies = [
  ('재무회계 기본서', '1권'),
  ('세법개론', '1권'),
  ('원가관리회계', '1권'),
  ('회계감사 요약서', '1권'),
  ('경영학 기출문제집', '1권'),
  ('오답노트', '2권'),
];

class PlanVideo {
  const PlanVideo(this.title, this.length, this.color, [this.thumb]);

  final String title;
  final String length;
  final Color color;
  final String? thumb;
}

const planVideos = [
  PlanVideo('회독 수 늘리는 법', '3:12', Color(0xFFDCE6FF), '$_img/video1.png'),
  PlanVideo('오답노트 쓰는 법', '4:05', Color(0xFFFFF0D6), '$_img/video2.png'),
  PlanVideo('시험장 시간 배분', '2:48', Color(0xFFE3F5EC)),
  PlanVideo('멘탈 관리', '5:20', Color(0xFFF3E8FF)),
];

class PlanStep {
  const PlanStep(this.week, this.when, this.title, this.body, this.tool);

  final String week;
  final String when;
  final String title;
  final String body;
  final String tool;
}

const planSteps = [
  PlanStep('1주차', '시험 30일 전부터 7일간', '약점 과목 진단', '기출 1회분을 시간 재고 풀어보고, 과목별 점수를 기록해 약한 과목부터 순서를 정해요.', '도구 · 오답노트'),
  PlanStep('2주차', '시험 23일 전부터 7일간', '2회독 + 오답 정리', '약점 과목은 하루 2과목씩, 나머지는 하루 1과목씩 빠르게 회독해요.', '도구 · 인강 2배속'),
  PlanStep('3주차', '시험 16일 전부터 7일간', '실전 모의고사', '주 3회 실제 시험 시간표 그대로 모의고사를 풀고, 그날 바로 채점해요.', '도구 · 스톱워치'),
  PlanStep('마지막 주', '시험 9일 전부터 시험 전날까지', '오답만 3회독', '새 문제는 풀지 않고 오답노트만 반복해요. 취침·기상 시간을 시험일에 맞춰요.', '도구 · 오답노트'),
];

/// 하루 루틴(시각, 제목, 담은 사람). 앞의 4개만 먼저 보인다.
const planRoutine = [
  ('07:00 AM', '기상 · 영양제', '312명이 담았어요'),
  ('08:00 AM', '재무회계 문제풀이 4h', '1,024명이 담았어요'),
  ('01:00 PM', '세법 회독 4h', '980명이 담았어요'),
  ('07:00 PM', '모의고사 1과목', '756명이 담았어요'),
  ('10:00 PM', '오답노트 정리', '688명이 담았어요'),
  ('11:30 PM', '취침', '540명이 담았어요'),
];

const authorBio = '2025 CPA 초시 동차 합격 · 경영학 비전공';

/// 후기(0902).
class PlanReview {
  const PlanReview({
    required this.user,
    required this.body,
    required this.stars,
    required this.date,
    required this.rate,
    this.passed = false,
    this.photos = const [],
    this.helpful = 42,
  });

  final CommunityUser user;
  final String body;
  final int stars;
  final String date;
  final int rate;
  final bool passed;
  final List<String> photos;
  final int helpful;
}

const planReviews = [
  PlanReview(
    user: _potato,
    passed: true,
    photos: ['$_img/photo1.png', '$_img/photo2.png'],
    rate: 92,
    body: '약점 진단부터 하니까 세법 비중을 확 늘릴 수 있었어요. 마지막 주 오답만 3회독이 진짜 효자였습니다. 덕분에 1차 붙었어요!',
    stars: 5,
    date: '2026.03.02',
  ),
  PlanReview(
    user: _afterWork,
    rate: 92,
    body: '직장 다니면서 하루 10시간은 어려워서 하루 루틴을 6시간 버전으로 줄여 썼어요. 그래도 주차별 흐름은 그대로 따라가니 불안함이 덜했어요.',
    stars: 4,
    date: '2026.02.18',
  ),
  PlanReview(
    user: _noBase,
    passed: true,
    photos: ['$_img/photo3.png'],
    rate: 88,
    body: '모의고사를 실제 시험 시간표대로 푼 게 시험장에서 제일 도움됐어요. 시간 배분 연습이 따로 필요 없었어요.',
    stars: 5,
    date: '2026.02.10',
  ),
];

/// 점수별 후기 수(5점→1점).
const reviewDistribution = [105, 17, 5, 1, 0];
const reviewInsights = [
  PlanStat('담은 횟수', '1,284'),
  PlanStat('평균 달성률', '76%', highlight: true),
  PlanStat('합격 인증', '23명'),
];

/// 댓글(0903). [replies]는 작성자 답글.
class PlanComment {
  PlanComment({required this.user, required this.time, required this.body, this.likes = 0, this.replies = const []});

  final CommunityUser user;
  final String time;
  final String body;
  int likes;
  bool liked = false;
  final List<PlanComment> replies;
}

List<PlanComment> samplePlanComments() => [
  PlanComment(
    user: const CommunityUser('스터디메이트', 12, CubeColors.yellow),
    time: '2시간 전',
    body: '모의고사는 몇 시에 푸셨어요? 실제 시험처럼 오전에 푸는 게 나을까요?',
    likes: 12,
    replies: [
      PlanComment(
        user: author,
        time: '1시간 전',
        body: '네! 실제 시험 시작 시간에 맞춰서 풀었어요. 그 시간에 집중하는 습관이 생겨서 시험장에서 덜 긴장됐어요.',
        likes: 8,
      ),
    ],
  )..liked = true,
  PlanComment(
    user: const CommunityUser('기출러', 3, CubeColors.green),
    time: '5시간 전',
    body: '기출문제집은 연도별로 푸셨나요, 과목별로 푸셨나요?',
    likes: 3,
  ),
  PlanComment(
    user: const CommunityUser('노베이스', 11, AppColors.brand),
    time: '어제',
    body: '비전공인데 D-60부터 시작하면 이 계획을 두 배로 늘려서 써도 될까요?',
    likes: 5,
    replies: [PlanComment(user: author, time: '어제', body: '주차별 구간을 2주씩으로 늘리면 돼요. 하루 루틴은 그대로 두는 걸 추천해요.', likes: 6)],
  ),
  PlanComment(
    user: const CommunityUser('오늘도출석', 1, CubeColors.red),
    time: '2일 전',
    body: '하루 루틴 전체 담기 해서 3일째 지키는 중이에요. 기상 시간이 제일 어렵네요 ㅎㅎ',
    likes: 21,
  ),
];

const pinnedNotice = '궁금한 점 남겨주시면 최대한 답변드릴게요. 교재 구매처는 준비물 탭의 [구매]를 확인해 주세요!';
const commentTotal = 56;
