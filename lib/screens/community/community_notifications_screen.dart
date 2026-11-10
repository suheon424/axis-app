import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import '../my/my_widgets.dart';
import 'community_data.dart';
import 'plan_detail_screen.dart';

/// 09-4 커뮤니티 · 알림 한 줄.
class CommunityNotice {
  const CommunityNotice(this.tag, this.tone, this.title, this.detail, {this.template});

  final String tag;
  final AxisTagTone tone;
  final String title;

  /// "비전공생의 CPA 공부 계획 · 10분 전"
  final String detail;

  /// 누르면 여는 템플릿(댓글 알림).
  final int? template;
}

const communityNoticesToday = [
  CommunityNotice('댓글', AxisTagTone.blue, '내 계획에 새 댓글이 달렸어요', '비전공생의 CPA 공부 계획 · 10분 전', template: 0),
  CommunityNotice('일정', AxisTagTone.red, '기획안 제출이 40분 밀렸어요', '남은 일정 3개를 다시 맞출 수 있어요 · 1시간 전'),
  CommunityNotice('배지', AxisTagTone.green, '‘각성의 순간’ 배지를 받았어요', '일정 7회 완료 · 3시간 전'),
];

const communityNoticesEarlier = [
  CommunityNotice('이벤트', AxisTagTone.orange, '친구 초대 이벤트가 4일 남았어요', '친구 1명만 더 초대하면 1,000P · 어제'),
  CommunityNotice('댓글', AxisTagTone.blue, '내 댓글에 좋아요 12개가 달렸어요', '-20kg 성공한 다이어트 루틴 · 2일 전', template: 1),
  CommunityNotice('공지', AxisTagTone.gray, '새 업데이트 11.23.0이 나왔어요', '틀어진 일정을 AI로 다시 맞춰요 · 11.23'),
];

/// 아직 읽지 않은 오늘 알림(0부터 순번). 화면을 나갔다 와도 남는다.
final communityUnread = ValueNotifier<Set<int>>({0, 1, 2});

/// 09-4 커뮤니티 · 알림(205:10441): "오늘"·"이전 알림" 묶음. 안 읽은 알림은 진한 제목 + N 배지,
/// 누르면 읽음으로 바뀌고 댓글 알림은 그 계획의 댓글 탭을 연다.
class CommunityNotificationsScreen extends StatelessWidget {
  const CommunityNotificationsScreen({super.key});

  void _open(BuildContext context, int index, CommunityNotice n) {
    communityUnread.value = {...communityUnread.value}..remove(index);
    final t = n.template;
    if (t != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => PlanDetailScreen(template: communityTemplates[t], initialTab: 2)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: '알림',
      body: ValueListenableBuilder(
        valueListenable: communityUnread,
        builder: (context, unread, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          children: [
            _GroupLabel('오늘', communityNoticesToday.length),
            for (final (i, n) in communityNoticesToday.indexed)
              _NoticeRow(
                notice: n,
                unread: unread.contains(i),
                divider: i < communityNoticesToday.length - 1,
                onTap: () => _open(context, i, n),
              ),
            const SizedBox(height: 28),
            _GroupLabel('이전 알림', communityNoticesEarlier.length),
            for (final (i, n) in communityNoticesEarlier.indexed)
              _NoticeRow(
                notice: n,
                unread: false,
                divider: i < communityNoticesEarlier.length - 1,
                onTap: () => _open(context, -1, n),
              ),
          ],
        ),
      ),
    );
  }
}

/// 묶음 머리줄: 12-4 내가 쓴 댓글의 "댓글 4"(MyCountHeader)와 같은 모양.
/// 14 SemiBold 이름 + 파란 개수, 아래 1px gray04 선(최소 높이 36, 선 위 8).
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text, this.count);

  final String text;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.only(bottom: 8),
      alignment: Alignment.bottomLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray04)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$text '),
            TextSpan(
              text: '$count',
              style: TextStyle(color: count > 0 ? AppColors.brand : AppColors.text),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
    );
  }
}

/// notification/n: 높이 96 · 위 14 태그(+ 안 읽음 N) · 제목 16 SemiBold · 설명 12 gray06 · 오른쪽 21 꺾쇠 · 아래 1px 선.
class _NoticeRow extends StatelessWidget {
  const _NoticeRow({required this.notice, required this.unread, required this.divider, required this.onTap});

  final CommunityNotice notice;
  final bool unread;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: '${notice.tag} ${notice.title}${unread ? ', 안 읽음' : ''}',
      scale: 1,
      onTap: onTap,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.only(top: 14, bottom: 13),
        decoration: BoxDecoration(
          color: pressed ? AppColors.gray01 : null,
          border: divider ? const Border(bottom: BorderSide(color: AppColors.gray02)) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AxisTag(notice.tag, tone: notice.tone),
                      if (unread) ...[const SizedBox(width: 4), const AxisNotificationBadge()],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notice.title,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: unread ? AppColors.text : AppColors.gray06,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(notice.detail, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray06)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const AxisChevronRight(size: 21, color: AppColors.gray05),
          ],
        ),
      ),
    );
  }
}
