import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'all_templates_screen.dart';
import 'community_data.dart';
import 'community_notifications_screen.dart';
import 'community_widgets.dart';
import 'plan_detail_screen.dart';

/// 탐색 탭 첫 화면(피그마 09_커뮤니티 130:12010, 로딩 상태 130:13683).
/// 처음 열면 인기 템플릿 자리에 스켈레톤이 잠깐 보인다(제목 "인기 계획 템플릿"을 길게 누르면 다시 보기).
/// 템플릿·후기 카드 → 0901 계획 상세, 검색창 → 검색 화면(결과 없음 130:14972).
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, this.loadingDuration = const Duration(milliseconds: 900)});

  /// 첫 로딩(스켈레톤) 시간. [Duration.zero]면 바로 목록.
  final Duration loadingDuration;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  static const _heroTop = Color(0xFF002261);
  bool _loading = false;
  final Set<int> _bookmarks = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (widget.loadingDuration == Duration.zero) return;
    setState(() => _loading = true);
    Future.delayed(widget.loadingDuration, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _open(CommunityTemplate t, {int tab = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlanDetailScreen(template: t, initialTab: tab),
      ),
    );
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what은(는) 준비 중이에요.')));
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay.copyWith(statusBarColor: _heroTop),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const AxisTabBar(current: MainTab.explore),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _Hero(
                topInset: topInset,
                bookmarkCount: _bookmarks.length,
                onSearch: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => CommunitySearchScreen(onOpen: _open))),
                onBookmarks: () => _soon('저장한 계획'),
                onBell: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => const CommunityNotificationsScreen())),
                onReview: (r) => _open(communityTemplates[r.template], tab: 1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onLongPress: _load,
                            child: const Text.rich(
                              TextSpan(
                                text: '인기 계획 템플릿 ',
                                children: [
                                  TextSpan(
                                    text: 'TOP10',
                                    style: TextStyle(color: CubeColors.blue),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              Navigator.of(context)
                                  .push(MaterialPageRoute<void>(builder: (_) => AllTemplatesScreen(onOpen: _open))),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 4, left: 8),
                            child: Row(
                              children: [
                                Text(
                                  '전체보기',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.gray06,
                                  ),
                                ),
                                AxisChevronRight(size: 17, color: AppColors.gray05),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '템플릿 적용으로 손쉽게 계획을 따라해보세요.',
                      style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 21),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _loading
                          ? const Column(
                              key: ValueKey('loading'),
                              children: [TemplateRowSkeleton(), TemplateRowSkeleton(), TemplateRowSkeleton()],
                            )
                          : Column(
                              key: const ValueKey('list'),
                              children: [
                                for (final t in communityTemplates)
                                  TemplateRow(
                                    template: t,
                                    bookmarked: _bookmarks.contains(t.rank),
                                    onBookmark: () => setState(
                                      () => _bookmarks.contains(t.rank)
                                          ? _bookmarks.remove(t.rank)
                                          : _bookmarks.add(t.rank),
                                    ),
                                    onTap: () => _open(t),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 위쪽 파란 영역: 검색창·북마크·알림, 문구, 3D 말풍선, 후기 카드 캐러셀.
class _Hero extends StatefulWidget {
  const _Hero({
    required this.topInset,
    required this.bookmarkCount,
    required this.onSearch,
    required this.onBookmarks,
    required this.onBell,
    required this.onReview,
  });

  final double topInset;
  final int bookmarkCount;
  final VoidCallback onSearch;
  final VoidCallback onBookmarks;
  final VoidCallback onBell;
  final ValueChanged<ReviewHighlight> onReview;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  final _cube = AxisCubeCarouselController();
  int _page = 0;

  /// 후기 카드 두 장이 한 면. 큐브 한 층을 돌리듯 면 단위로 넘어간다.
  static const _perFace = 2;

  @override
  Widget build(BuildContext context) {
    final count = (reviewHighlights.length / _perFace).ceil();
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE3ECF6),
        image: DecorationImage(image: AssetImage('assets/images/community/hero_bg.png'), fit: BoxFit.fill),
      ),
      padding: EdgeInsets.only(top: widget.topInset + 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 13),
            child: Row(
              children: [
                Expanded(child: _SearchPill(onTap: widget.onSearch)),
                const SizedBox(width: 3),
                AxisIconButton(
                  icon: KitIcon.navBookmark,
                  tooltip: '저장한 계획',
                  color: Colors.white,
                  onPressed: widget.onBookmarks,
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AxisIconButton(icon: KitIcon.navBell, tooltip: '알림', color: Colors.white, onPressed: widget.onBell),
                    const Positioned(right: 3, top: 2, child: IgnorePointer(child: AxisNotificationBadge(count: 1))),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 112,
            child: Stack(
              children: [
                Positioned(
                  right: 18,
                  top: 18,
                  child: Image.asset('assets/images/community/bubble.png', width: 110, height: 100),
                ),
                const Positioned(
                  left: 20,
                  top: 21,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '혼자 짜는 막막한\n계획은 이제 그만!',
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.3,
                          letterSpacing: -0.22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 9),
                      Text(
                        '메이트들의 생생 후기를 둘러보세요!',
                        style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xCC000000)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 19),
          // 시안 "09 커뮤니티 · 한 층 돌리기": 카드 두 장씩 붙은 면이 기둥처럼 90°씩 돈다.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, c) => AxisCubeCarousel(
                controller: _cube,
                size: Size(c.maxWidth, 151),
                faceCount: count,
                onChanged: (p) => setState(() => _page = p),
                faceBuilder: (context, face, dim) => Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < _perFace; j++) ...[
                      if (j > 0) const SizedBox(width: 10),
                      Expanded(
                        child: face * _perFace + j < reviewHighlights.length
                            ? _ReviewCard(
                                review: reviewHighlights[face * _perFace + j],
                                dim: dim,
                                onTap: () => widget.onReview(reviewHighlights[face * _perFace + j]),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PageArrow(left: true, enabled: true, onTap: _cube.previous),
              const SizedBox(width: 6),
              Text.rich(
                TextSpan(
                  text: '${_page + 1}',
                  children: [
                    TextSpan(
                      text: ' / $count',
                      style: const TextStyle(color: AppColors.subIcon),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: communityText),
              ),
              const SizedBox(width: 6),
              _PageArrow(left: false, enabled: true, onTap: _cube.next),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '계획 검색',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(color: const Color(0x801F2027), borderRadius: BorderRadius.circular(6)),
          child: const Row(
            children: [
              AxisIcon(KitIcon.navSearch, size: 16, color: Colors.white),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  '관심 있는 계획을 검색해보세요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, height: 1.4, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({required this.left, required this.enabled, required this.onTap});

  final bool left;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = AxisIcon(KitIcon.navBack, size: 21, color: AppColors.gray06);
    return Semantics(
      button: true,
      enabled: enabled,
      label: left ? '이전 후기' : '다음 후기',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(child: left ? icon : Transform.flip(flipX: true, child: icon)),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onTap, this.dim = 0});

  final ReviewHighlight review;
  final VoidCallback onTap;

  /// 큐브 옆면으로 돌아간 만큼 덮는 검정 불투명도.
  final double dim;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      onTap: onTap,
      semanticLabel: review.title.replaceAll('\n', ' '),
      builder: (context, pressed) => Container(
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        foregroundDecoration: dim > 0
            ? BoxDecoration(
                color: Colors.black.withValues(alpha: dim),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                height: 1.375,
                letterSpacing: -0.32,
                fontWeight: FontWeight.w600,
                color: communityText,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              review.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, height: 1.33, fontWeight: FontWeight.w500, color: communitySub),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: starColor),
                const SizedBox(width: 2),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray06,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.author,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray06,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 템플릿 검색(검색 결과 없음 130:14972). 제목·설명·분류에 검색어가 들어간 템플릿을 보여 준다.
class CommunitySearchScreen extends StatefulWidget {
  const CommunitySearchScreen({super.key, this.initialQuery = '', this.onOpen});

  final String initialQuery;

  /// 결과를 눌렀을 때. null이면 검색 화면에서 바로 상세를 연다.
  final void Function(CommunityTemplate template)? onOpen;

  @override
  State<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends State<CommunitySearchScreen> {
  late final _q = TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<CommunityTemplate> get _results {
    final words = _query.trim().toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return const [];
    return communityTemplates.where((t) {
      final hay = '${t.title} ${t.description} ${t.category}'.toLowerCase();
      return words.every(hay.contains);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final searched = _query.trim().isNotEmpty;
    final results = _results;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 20, 0),
                child: Row(
                  children: [
                    AxisIconButton.back(onPressed: () => Navigator.of(context).maybePop()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const AxisIcon(KitIcon.navSearch, size: 16, color: AppColors.gray06),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _q,
                                autofocus: widget.initialQuery.isEmpty,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (v) => setState(() => _query = v),
                                onChanged: (v) => setState(() => _query = v),
                                style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.gray07),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  hintText: '관심 있는 계획을 검색해보세요',
                                  hintStyle: TextStyle(fontSize: 14, height: 1.4, color: AppColors.subIcon),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (searched) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.gray03)),
                    ),
                    child: Text(
                      '검색 결과 ${results.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: communityText,
                      ),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: !searched
                    ? const SizedBox.shrink()
                    : results.isEmpty
                    ? Align(
                        alignment: const Alignment(0, -0.55),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CommunityEmpty(
                            icon: Icons.search_rounded,
                            title: "'${_query.trim()}' 검색 결과가 없어요",
                            description: '철자를 확인하거나\n다른 키워드로 검색해 보세요.',
                            actionLabel: '인기 템플릿 둘러보기',
                            onAction: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          for (final t in results)
                            TemplateRow(
                              template: t,
                              onTap: () => widget.onOpen != null
                                  ? widget.onOpen!(t)
                                  : Navigator.of(context)
                                        .push(MaterialPageRoute<void>(builder: (_) => PlanDetailScreen(template: t))),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
