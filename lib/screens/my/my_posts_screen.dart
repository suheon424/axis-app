import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_data.dart';
import 'my_widgets.dart';

/// 12-3 내가 쓴 게시물(130:13115): "게시물 3" + 전체 필터 + 게시물 목록(⋮로 삭제).
/// 모두 지우면 빈 상태(130:14441). 데모: 머리줄을 길게 누르면 빈 상태로 바뀐다.
class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key, this.posts = sampleMyPosts});

  final List<MyPost> posts;

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  static const _kinds = ['전체', '플랜', '후기'];
  late List<MyPost> _posts = [...widget.posts];
  String _kind = _kinds.first;

  Future<void> _pickKind() async {
    final picked = await showAxisSheet<String>(
      context,
      title: '게시물 종류',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final k in _kinds) AxisMenuRow(label: k, showChevron: false, onTap: () => Navigator.pop(ctx, k)),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (picked != null) setState(() => _kind = picked);
  }

  Future<void> _more(MyPost post) async {
    final action = await showAxisSheet<String>(
      context,
      title: post.title,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AxisMenuRow(label: '수정하기', showChevron: false, onTap: () => Navigator.pop(ctx, 'edit')),
            AxisMenuRow(label: '삭제하기', showChevron: false, onTap: () => Navigator.pop(ctx, 'delete')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      showAxisToast(context, '게시물 수정은 탐색 탭에서 할 수 있어요.');
      return;
    }
    final ok = await showAxisConfirm(context, title: '게시물을 삭제할까요?', message: '삭제한 게시물은 되돌릴 수 없어요.', confirmLabel: '삭제');
    if (ok == true && mounted) {
      setState(() => _posts.remove(post));
      showAxisToast(context, '게시물을 삭제했어요');
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _kind == _kinds.first ? _posts : _posts.where((p) => p.kind == _kind).toList();
    return MySubScaffold(
      title: '내가 쓴 게시물',
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 32),
        children: [
          MyCountHeader(
            label: '게시물',
            count: visible.length,
            onLongPress: () => setState(() => _posts = _posts.isEmpty ? [...widget.posts] : []),
            trailing: _posts.isEmpty ? null : _KindDropdown(label: _kind, onTap: _pickKind),
          ),
          const SizedBox(height: 10),
          if (_posts.isEmpty)
            MyEmptyState(
              icon: KitIcon.menuPost,
              title: '아직 작성한 게시물이 없어요',
              description: '나의 계획과 후기를 공유하고\n메이트들의 응원을 받아보세요.',
              actionLabel: '첫 게시물 쓰기',
              onAction: () => MainTabRouter.open(context, MainTab.explore),
            )
          else
            for (final p in visible) _PostRow(post: p, onMore: () => _more(p)),
        ],
      ),
    );
  }
}

class _KindDropdown extends StatelessWidget {
  const _KindDropdown({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '게시물 종류 $label',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 26, minWidth: 56),
          padding: const EdgeInsets.only(left: 8, right: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray02),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.gray07),
              ),
              const SizedBox(width: 2),
              const AxisIcon(KitIcon.chevronDownSmall, size: 15, color: AppColors.subIcon),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post, required this.onMore});

  final MyPost post;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    const meta = TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF6B7684));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray02)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // thumb: 40 정사각 사진, 굴곡 8, 줄 위에서 20.
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(post.thumb, width: 40, height: 40, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 6),
                Text(post.summary, style: meta),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const AxisIcon(KitIcon.smallBookmarkOff, size: 14),
                    const SizedBox(width: 4),
                    Text('${post.bookmarks}', style: meta.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(post.meta, style: AxisText.caption)),
                  ],
                ),
              ],
            ),
          ),
          // 세로 ⋮: 24px 아이콘이 제목 줄과 나란히 오도록 44px 탭 영역을 위·오른쪽으로 10 당긴다.
          Transform.translate(
            offset: const Offset(10, -10),
            child: RotatedBox(
              quarterTurns: 1,
              child: AxisIconButton(icon: KitIcon.navMore, tooltip: '더보기', onPressed: onMore),
            ),
          ),
        ],
      ),
    );
  }
}
