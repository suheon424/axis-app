import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_data.dart';
import 'my_widgets.dart';

/// 12-4 내가 쓴 댓글(130:13162): "댓글 4" + 게시물 제목·날짜·좋아요 + 댓글 본문.
/// 비면 빈 상태(130:14488). 데모: 머리줄을 길게 누르면 빈 상태로 바뀐다.
class MyCommentsScreen extends StatefulWidget {
  const MyCommentsScreen({super.key, this.comments = sampleMyComments});

  final List<MyComment> comments;

  @override
  State<MyCommentsScreen> createState() => _MyCommentsScreenState();
}

class _MyCommentsScreenState extends State<MyCommentsScreen> {
  late List<MyComment> _comments = widget.comments;

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: '내가 쓴 댓글',
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 32),
        children: [
          MyCountHeader(
            label: '댓글',
            count: _comments.length,
            onLongPress: () => setState(() => _comments = _comments.isEmpty ? widget.comments : const []),
          ),
          if (_comments.isEmpty)
            MyEmptyState(
              icon: KitIcon.menuComment,
              title: '아직 남긴 댓글이 없어요',
              description: '마음에 드는 계획에\n응원 한마디를 남겨보세요.',
              actionLabel: '커뮤니티 둘러보기',
              outline: true,
              onAction: () => MainTabRouter.open(context, MainTab.explore),
            )
          else
            for (final c in _comments) _CommentRow(comment: c),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});

  final MyComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(comment.postTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AxisText.caption),
              ),
              Text(comment.date, style: AxisText.caption.copyWith(color: AppColors.subIcon)),
              const SizedBox(width: 8),
              const AxisIcon(KitIcon.smallLikeOff, size: 14),
              const SizedBox(width: 4),
              Text('${comment.likes}', style: AxisText.caption),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.body, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}
