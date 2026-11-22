import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_data.dart';
import 'my_widgets.dart';

/// 12-6 공지사항(130:13227): 종류 태그(업데이트·이벤트·공지) + 새 글 N + 제목 + 날짜, 누르면 본문.
class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: '공지사항',
      body: ListView(
        padding: const EdgeInsets.only(top: 6, bottom: 32),
        children: [
          for (final n in sampleNotices)
            _NoticeRow(
              notice: n,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MyDocumentScreen(
                    title: '공지사항',
                    heading: n.title,
                    date: n.date,
                    tag: AxisTag(n.kind.label, tone: n.kind.tone),
                    body: n.body,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow({required this.notice, required this.onTap});

  final Notice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: '${notice.kind.label}, ${notice.title}, ${notice.date}',
      onTap: onTap,
      scale: 1,
      builder: (_, pressed) => Container(
        color: pressed ? AppColors.gray01 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray02)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AxisTag(notice.kind.label, tone: notice.kind.tone),
                        if (notice.isNew) ...[const SizedBox(width: 4), const AxisNotificationBadge()],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notice.title, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text(notice.date, style: AxisText.caption),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const AxisChevronRight(color: AppColors.gray05),
            ],
          ),
        ),
      ),
    );
  }
}

/// 공지 본문·약관 같은 글 한 편을 보여 주는 화면(피그마 프레임 없음, 마이 탭 공통 스타일).
class MyDocumentScreen extends StatelessWidget {
  const MyDocumentScreen({
    super.key,
    required this.title,
    required this.heading,
    required this.body,
    this.date,
    this.tag,
  });

  final String title;
  final String heading;
  final String body;
  final String? date;
  final Widget? tag;

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: title,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          if (tag != null) ...[Align(alignment: Alignment.centerLeft, child: tag), const SizedBox(height: 8)],
          Text(heading, style: AxisText.title18.copyWith(color: AppColors.text)),
          if (date != null) ...[const SizedBox(height: 6), Text(date!, style: AxisText.caption)],
          const SizedBox(height: 16),
          const AxisDivider(),
          const SizedBox(height: 16),
          Text(body, style: AxisText.body.copyWith(color: AppColors.gray07, height: 1.6)),
        ],
      ),
    );
  }
}
