import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/address_suggestions.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import 'address_detail_screen.dart';

/// 5-3 · 주소 검색 화면. 검색창에 입력하면 아래에 관련 주소가 관련순으로 뜨고, 하나를 고르거나
/// 검색(키보드 완료 또는 돋보기)하면 상세 주소 입력 화면으로 넘어간다. 거기서 등록한 주소를
/// 이전 화면으로 돌려준다.
class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key, this.initial});

  final String? initial;

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  late final _controller = TextEditingController(text: widget.initial)..addListener(_onQueryChanged);
  late String _query = _controller.text.trim();
  late List<AddressSuggestion> _results = searchAddresses(_query);

  void _onQueryChanged() {
    final query = _controller.text.trim();
    if (query == _query) return;
    setState(() {
      _query = query;
      _results = searchAddresses(query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit([String? value]) {
    final text = (value ?? _controller.text).trim();
    if (text.isEmpty) return;
    _openDetail(AddressSuggestion(text, text));
  }

  Future<void> _openDetail(AddressSuggestion picked) async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => AddressDetailScreen(suggestion: picked)),
    );
    if (result != null && mounted) Navigator.of(context).pop(result);
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const divider = BorderSide(color: AppColors.gray03);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.searchBg,
        body: SafeArea(
          child: Column(
            children: [
              // 검색창: 뒤로 · 입력 · 음성 | 검색
              Container(
                height: 50,
                decoration: const BoxDecoration(border: Border(bottom: divider)),
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '뒤로',
                      // 기기마다 버튼 크기가 달라지지 않게 40으로 고정(아이콘 왼쪽 20, 입력 시작 56).
                      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: SvgPicture.asset(
                        'assets/icons/ic_arrow_left.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(AppColors.icon, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _submit,
                        style: const TextStyle(fontSize: 16, color: AppColors.gray07),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: '장소, 주소 검색',
                          hintStyle: TextStyle(fontSize: 16, color: AppColors.gray07.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    _IconTap(
                      tooltip: '음성 검색',
                      asset: 'assets/icons/ic_mic.svg',
                      width: 17,
                      height: 18,
                      onTap: () => _notice('음성 검색은 준비 중이에요.'),
                    ),
                    Container(width: 1, height: 19, color: AppColors.gray03),
                    _IconTap(tooltip: '검색', asset: 'assets/icons/ic_search.svg', width: 18, height: 18, onTap: _submit),
                  ],
                ),
              ),
              // 내위치 · 지도에서 찾기
              Container(
                height: 40,
                decoration: const BoxDecoration(border: Border(bottom: divider)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QuickAction(
                      asset: 'assets/icons/ic_my_location.svg',
                      label: '내위치',
                      color: AppColors.primary,
                      onTap: () => _notice('내 위치 찾기는 위치 권한 연동 후 사용할 수 있어요.'),
                    ),
                    const SizedBox(width: 50),
                    _QuickAction(
                      asset: 'assets/icons/ic_map.svg',
                      label: '지도에서 찾기',
                      color: Colors.black,
                      onTap: () => _notice('지도에서 찾기는 준비 중이에요.'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _query.isEmpty
                      ? const _SearchTips(key: ValueKey('tips'))
                      : _results.isEmpty
                      ? _EmptyResult(key: const ValueKey('empty'), query: _query)
                      : ListView.builder(
                          key: const ValueKey('results'),
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: _results.length,
                          itemBuilder: (context, i) => _SuggestionTile(
                            suggestion: _results[i],
                            query: _query,
                            onTap: () => _openDetail(_results[i]),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 자동완성 한 줄: 장소 이름과 도로명 주소. 입력한 글자는 파란색으로 강조한다.
class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.query, required this.onTap});

  final AddressSuggestion suggestion;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray03)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              _highlight(
                suggestion.name,
                query,
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray07),
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(_highlight(suggestion.address, query, const TextStyle(fontSize: 13, color: AppColors.subText))),
          ],
        ),
      ),
    );
  }
}

/// [text] 안에서 검색어(띄어쓴 단어 각각)와 같은 부분을 파란색으로 칠한다.
TextSpan _highlight(String text, String query, TextStyle style) {
  final tokens = query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  final lower = text.toLowerCase();
  final marked = List<bool>.filled(text.length, false);
  for (final token in tokens) {
    for (var i = lower.indexOf(token); i >= 0; i = lower.indexOf(token, i + token.length)) {
      marked.fillRange(i, i + token.length, true);
    }
  }
  final spans = <TextSpan>[];
  var start = 0;
  for (var i = 1; i <= text.length; i++) {
    if (i == text.length || marked[i] != marked[start]) {
      spans.add(
        TextSpan(
          text: text.substring(start, i),
          style: marked[start] ? const TextStyle(color: AppColors.primary) : null,
        ),
      );
      start = i;
    }
  }
  return TextSpan(style: style, children: spans);
}

/// 검색어가 없을 때 보여 주는 검색 요령.
class _SearchTips extends StatelessWidget {
  const _SearchTips({super.key});

  static const _tips = [
    ('도로명 + 건물번호', '예) 삼선교로16길 116'),
    ('동/읍/면 + 번지', '예) 삼선동 2가 389'),
    ('건물명, 아파트명', '예) 한성대학교'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 24, AppSizes.sidePadding, 24),
      children: [
        const Text(
          '이렇게 검색해 보세요',
          style: TextStyle(fontSize: 16, height: 1.2, fontWeight: FontWeight.w700, color: AppColors.gray07),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, (title, example)) in _tips.indexed) ...[
                if (i > 0) const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.w500, color: AppColors.gray07),
                ),
                const SizedBox(height: 2),
                Text(example, style: const TextStyle(fontSize: 13, height: 1.2, color: AppColors.primary)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '집 주소는 출발 시간 계산에만 사용되며,\n다른 사람에게 공개되지 않아요.',
          style: TextStyle(fontSize: 13, height: 1.2, color: AppColors.caption),
        ),
      ],
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 40, AppSizes.sidePadding, 0),
      child: Text(
        "'$query' 검색 결과가 없어요.\n검색 버튼을 누르면 입력한 그대로 쓸 수 있어요.",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({
    required this.tooltip,
    required this.asset,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final String tooltip;
  final String asset;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: SvgPicture.asset(asset, width: width, height: height),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.asset, required this.label, required this.color, required this.onTap});

  final String asset;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(asset, width: 15, height: 15),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}
