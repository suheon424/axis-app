import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'community_data.dart';
import 'community_widgets.dart';
import 'plan_overview_tab.dart';

/// 0903 댓글 탭: 개수·정렬 → 작성자 고정 글 → 댓글(작성자 답글은 들여 쓰고 이음선). 비어 있으면 빈 상태(130:14595).
class PlanCommentsTab extends StatefulWidget {
  const PlanCommentsTab({
    super.key,
    required this.comments,
    required this.onReply,
    required this.onChanged,
    required this.onToast,
  });

  final List<PlanComment> comments;
  final ValueChanged<PlanComment> onReply;
  final VoidCallback onChanged;
  final ToastFn onToast;

  @override
  State<PlanCommentsTab> createState() => _PlanCommentsTabState();
}

class _PlanCommentsTabState extends State<PlanCommentsTab> {
  /// 인기순은 운영자가 고른 순서, 최신순은 시간순(예시 데이터는 두 순서가 같다). 새 댓글은 맨 위.
  bool _latest = false;

  void _like(PlanComment c) {
    setState(() {
      c.liked = !c.liked;
      c.likes += c.liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.comments;
    final total = comments.isEmpty ? 0 : commentTotal + comments.length - 4;
    final shown = comments;
    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '댓글 ${total < 0 ? comments.length : total}',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: communityText,
                    ),
                  ),
                ),
                _SortLabel(label: '인기순', on: !_latest, onTap: () => setState(() => _latest = false)),
                Container(
                  width: 1,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: const Color(0xFFD1D6DB),
                ),
                _SortLabel(label: '최신순', on: _latest, onTap: () => setState(() => _latest = true)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameRow(name: author.name, isAuthor: true),
                  const SizedBox(height: 2),
                  const Text(pinnedNotice, style: TextStyle(fontSize: 12, height: 1.4, color: communityBody)),
                ],
              ),
            ),
          ),
          if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 48, 20, 48),
              child: CommunityEmpty(
                icon: Icons.chat_bubble_outline_rounded,
                title: '아직 댓글이 없어요',
                description: '궁금한 점이나 응원 한마디를\n가장 먼저 남겨보세요.',
              ),
            )
          else ...[
            const SizedBox(height: 8),
            for (var i = 0; i < shown.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    border: i < shown.length - 1 ? const Border(bottom: BorderSide(color: AppColors.gray02)) : null,
                  ),
                  child: _CommentItem(
                    comment: shown[i],
                    onLike: _like,
                    onReply: widget.onReply,
                    onMore: (c) => widget.onToast('신고·차단은 준비 중이에요'),
                  ),
                ),
              ),
            // 🧩 axis Components의 Button/Text(130:9211).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextLinkButton(
                label: '댓글 ${(total - shown.length).clamp(0, 9999)}개 더보기',
                onPressed: () => widget.onToast('댓글을 더 불러오는 중이에요'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SortLabel extends StatelessWidget {
  const _SortLabel({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: on,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                color: on ? communityText : AppColors.gray06,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.name, this.time, this.isAuthor = false});

  final String name;
  final String? time;
  final bool isAuthor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: communityText),
        ),
        if (time != null) Text(time!, style: AxisText.caption),
        if (isAuthor) const AxisTag('작성자'),
      ],
    );
  }
}

class _CommentItem extends StatefulWidget {
  const _CommentItem({
    required this.comment,
    required this.onLike,
    required this.onReply,
    required this.onMore,
    this.reply = false,
    this.avatarKey,
  });

  final PlanComment comment;
  final ValueChanged<PlanComment> onLike;
  final ValueChanged<PlanComment> onReply;
  final ValueChanged<PlanComment> onMore;
  final bool reply;

  /// 답글의 프로필 사진에 붙이는 키(위 댓글이 Vector 15 연결선을 여기까지 긋는다).
  final GlobalKey? avatarKey;

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  final _self = GlobalKey();
  final _firstReplyAvatar = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final item = _build(context);
    if (widget.reply || widget.comment.replies.isEmpty) return item;
    // Vector 15: 댓글 사진 아래에서 첫 답글 사진까지 내려와 오른쪽으로 꺾이는 2px #E5E8EB 선(굴곡 10).
    return CustomPaint(
      key: _self,
      painter: _ReplyConnectorPainter(self: _self, anchor: _firstReplyAvatar),
      child: item,
    );
  }

  Widget _build(BuildContext context) {
    final c = widget.comment;
    final reply = widget.reply;
    final onLike = widget.onLike, onReply = widget.onReply, onMore = widget.onMore;
    final likeColor = c.liked ? AppColors.brand : AppColors.gray06;
    return Padding(
      padding: EdgeInsets.only(top: reply ? 10 : 16, bottom: reply ? 4 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyedSubtree(
            key: widget.avatarKey,
            child: CommunityAvatar(c.user, size: reply ? 28 : 36),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _NameRow(name: c.user.name, time: c.time, isAuthor: c.user == author),
                    ),
                    Semantics(
                      button: true,
                      label: '더보기',
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () => onMore(c),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.more_horiz_rounded, size: 18, color: AppColors.radioBorder),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.body, style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF333D4B))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Semantics(
                      button: true,
                      selected: c.liked,
                      label: '좋아요 ${c.likes}',
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onLike(c),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              AxisIcon(c.liked ? KitIcon.smallLikeOn : KitIcon.smallLikeOff, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${c.likes}',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.33,
                                  fontWeight: FontWeight.w500,
                                  color: likeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!reply) ...[
                      const SizedBox(width: 14),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onReply(c),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '답글 달기',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.33,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray06,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                for (var i = 0; i < c.replies.length; i++)
                  _CommentItem(
                    comment: c.replies[i],
                    onLike: onLike,
                    onReply: onReply,
                    onMore: onMore,
                    reply: true,
                    avatarKey: i == 0 ? _firstReplyAvatar : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vector 15(0903 댓글): 댓글 사진 가운데 아래에서 시작해 첫 답글 사진 위에서 17.5 내려온 높이까지 내려온 뒤
/// 굴곡 10으로 꺾여 답글 사진 왼쪽 끝(+0.5)까지 가는 2px #E5E8EB 선.
class _ReplyConnectorPainter extends CustomPainter {
  _ReplyConnectorPainter({required this.self, required this.anchor});

  final GlobalKey self;
  final GlobalKey anchor;

  static const _color = Color(0xFFE5E8EB);

  @override
  void paint(Canvas canvas, Size size) {
    final me = self.currentContext?.findRenderObject() as RenderBox?;
    final avatar = anchor.currentContext?.findRenderObject() as RenderBox?;
    if (me == null || avatar == null || !me.attached || !avatar.attached) return;
    final a = avatar.localToGlobal(Offset.zero, ancestor: me);
    const x = 18.0, top = 16.0 + 36.0, r = 10.0;
    final y = a.dy + 17.5;
    final endX = a.dx + 0.5;
    if (y - r <= top) return;
    final path = Path()
      ..moveTo(x, top)
      ..lineTo(x, y - r)
      ..arcToPoint(Offset(x + r, y), radius: const Radius.circular(r), clockwise: false)
      ..lineTo(endX, y);
    canvas.drawPath(
      path,
      Paint()
        ..color = _color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_ReplyConnectorPainter old) => true;
}
