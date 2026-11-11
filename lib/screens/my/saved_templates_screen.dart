import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_data.dart';
import 'my_widgets.dart';

/// 12-5 찜한 템플릿(130:13203): "저장한 템플릿 3" + 썸네일(순위·북마크) + 템플릿 정보.
/// 썸네일의 북마크를 누르면 저장이 풀리고, 모두 풀면 빈 상태(130:13658). 데모: 머리줄 길게 누르기.
class SavedTemplatesScreen extends StatefulWidget {
  const SavedTemplatesScreen({super.key, this.templates = sampleSavedTemplates});

  final List<SavedTemplate> templates;

  @override
  State<SavedTemplatesScreen> createState() => _SavedTemplatesScreenState();
}

class _SavedTemplatesScreenState extends State<SavedTemplatesScreen> {
  late List<SavedTemplate> _items = [...widget.templates];

  void _unsave(SavedTemplate t) {
    final index = _items.indexOf(t);
    setState(() => _items.remove(t));
    showAxisToast(context, '저장을 취소했어요', actionLabel: '되돌리기', onAction: () => setState(() => _items.insert(index, t)));
  }

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: '저장한 템플릿',
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 32),
        children: [
          MyCountHeader(
            label: '저장한 템플릿',
            count: _items.length,
            onLongPress: () => setState(() => _items = _items.isEmpty ? [...widget.templates] : []),
          ),
          if (_items.isEmpty)
            MyEmptyState(
              icon: KitIcon.navBookmark,
              title: '아직 저장한 템플릿이 없어요',
              description: '마음에 드는 계획을 북마크해 두면 여기에 모여요.',
              actionLabel: '인기 템플릿 둘러보기',
              onAction: () => MainTabRouter.open(context, MainTab.explore),
            )
          else ...[
            const SizedBox(height: 10),
            for (var i = 0; i < _items.length; i++)
              _TemplateRow(rank: i + 1, template: _items[i], onUnsave: () => _unsave(_items[i])),
          ],
        ],
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.rank, required this.template, required this.onUnsave});

  final int rank;
  final SavedTemplate template;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDEE2E6))),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 82,
              height: 82,
              child: Stack(
                children: [
                  Positioned.fill(child: Image.asset(template.image, fit: BoxFit.cover)),
                  Positioned(left: 0, top: 0, child: AxisRankBadge(rank, top: rank == 1)),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Semantics(
                      button: true,
                      label: '저장 취소',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onUnsave,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 4, 6),
                          child: AxisIcon(KitIcon.navBookmarkOn, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: AxisTemplateInfo(
              title: template.title,
              description: template.description,
              meta: template.duration,
              footnote: template.footnote,
            ),
          ),
        ],
      ),
    );
  }
}
