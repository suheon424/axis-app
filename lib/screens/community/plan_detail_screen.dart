import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'community_data.dart';
import 'plan_comments_tab.dart';
import 'plan_overview_tab.dart';
import 'plan_reviews_tab.dart';

/// 계획 상세(피그마 0901 계획서 130:12125 · 0902 후기 130:12367 · 0903 댓글 130:12535).
/// 세 프레임은 같은 화면의 탭이다. 아래 "일정에 추가하기"를 누르면 "내 일정에 담았어요" 토스트(0901 · 일정 담기 완료 130:15157).
/// 댓글 탭은 아래 버튼 대신 댓글 입력창이 붙고, 댓글이 없으면 빈 상태(130:14595).
class PlanDetailScreen extends StatefulWidget {
  const PlanDetailScreen({super.key, required this.template, this.initialTab = 0, this.comments});

  final CommunityTemplate template;

  /// 0 계획서 · 1 후기 · 2 댓글
  final int initialTab;

  /// 댓글 목록. null이면 예시 댓글, 빈 목록이면 댓글 빈 상태.
  final List<PlanComment>? comments;

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  late int _tab = widget.initialTab;
  late final List<PlanComment> _comments = widget.comments ?? samplePlanComments();
  final _commentInput = TextEditingController();
  final _commentFocus = FocusNode();
  bool _bookmarked = false;

  static const _toastBottom = AxisTabBar.height + 76 + 12;

  @override
  void initState() {
    super.initState();
    _commentInput.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _commentInput.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _toast(String message, {String? action, VoidCallback? onAction}) =>
      showAxisToast(context, message, actionLabel: action, onAction: onAction, bottom: _toastBottom);

  void _addToSchedule() {
    _toast('내 일정에 담았어요', action: '보기', onAction: () => MainTabRouter.open(context, MainTab.home));
  }

  void _submitComment() {
    final text = _commentInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(0, PlanComment(user: const CommunityUser('나', 5, AppColors.gray05), time: '방금', body: text));
      _commentInput.clear();
    });
    _commentFocus.unfocus();
    _toast('댓글을 남겼어요');
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_tab) {
      0 => PlanOverviewTab(
        key: const ValueKey(0),
        template: widget.template,
        bookmarked: _bookmarked,
        onBookmark: () => setState(() => _bookmarked = !_bookmarked),
        onToast: _toast,
      ),
      1 => PlanReviewsTab(key: const ValueKey(1), onToast: _toast),
      _ => PlanCommentsTab(
        key: const ValueKey(2),
        comments: _comments,
        onReply: (c) {
          _commentInput.text = '@${c.user.name} ';
          _commentFocus.requestFocus();
        },
        onChanged: () => setState(() {}),
        onToast: _toast,
      ),
    };
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AxisBackShareBar(title: '템플릿', onShare: () => _toast('공유 링크를 복사했어요')),
              AxisSegmentedTabs(
                labels: const ['계획서', '후기', '댓글'],
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              Expanded(
                child: ColoredBox(
                  color: AppColors.gray01,
                  child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E8EB))),
              ),
              padding: EdgeInsets.fromLTRB(20, _tab == 2 ? 10 : 12, 20, _tab == 2 ? 10 : 12),
              child: _tab == 2
                  ? _CommentInput(controller: _commentInput, focusNode: _commentFocus, onSubmit: _submitComment)
                  : AxisCtaButton(label: '일정에 추가하기', onPressed: _addToSchedule),
            ),
            const AxisTabBar(current: MainTab.explore),
          ],
        ),
      ),
    );
  }
}

/// 0903 아래 댓글 입력창: 회색 상자 + "등록"(글자를 쓰면 파랑).
class _CommentInput extends StatelessWidget {
  const _CommentInput({required this.controller, required this.focusNode, required this.onSubmit});

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final ready = controller.text.trim().isNotEmpty;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => onSubmit(),
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.gray07),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintText: '댓글을 남겨주세요',
                hintStyle: TextStyle(fontSize: 14, height: 1.4, color: AppColors.subIcon),
              ),
            ),
          ),
          Semantics(
            button: true,
            enabled: ready,
            label: '등록',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: ready ? onSubmit : null,
              child: Container(
                constraints: const BoxConstraints(minWidth: 52, minHeight: 32),
                alignment: Alignment.center,
                child: Text(
                  '등록',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: ready ? AppColors.brand : AppColors.radioBorder,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
