import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'badge_celebration.dart';
import 'badge_data.dart';
import 'badge_detail_screen.dart';
import 'badge_widgets.dart';

enum _Filter { all, earned, locked }

extension on _Filter {
  String get label => const ['전체', '획득', '미획득'][index];
}

/// 11_뱃지보관함(130:15431). 10-6 이벤트와 마이 화면에서 연다.
/// 획득한 배지·획득 전 배지를 3칸씩 보여 주고, 칸을 누르면 배지 상세로 간다.
/// "획득한 배지" 제목을 길게 누르면 배지 획득 축하(11-1)를 미리 볼 수 있다.
class BadgeStorageScreen extends StatefulWidget {
  const BadgeStorageScreen({super.key});

  @override
  State<BadgeStorageScreen> createState() => _BadgeStorageScreenState();
}

class _BadgeStorageScreenState extends State<BadgeStorageScreen> {
  _Filter _filter = _Filter.all;

  void _open(BadgeInfo badge) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BadgeDetailScreen(badge: badge)));
  }

  @override
  Widget build(BuildContext context) {
    final earned = badgeCatalog.where((b) => b.earned).toList();
    final locked = badgeCatalog.where((b) => !b.earned).toList();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AxisBackTitleBar(title: '배지 보관함'),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  children: [
                    if (_filter != _Filter.locked) ...[
                      _SectionHeader(
                        title: '획득한 배지',
                        count: earned.length,
                        onLongPress: () => showBadgeCelebration(context, medal: AxisMedal.awakening),
                        trailing: _FilterButton(value: _filter, onChanged: (f) => setState(() => _filter = f)),
                      ),
                      _BadgeGrid(badges: earned, onTap: _open),
                      const SizedBox(height: 18),
                    ],
                    _SectionHeader(
                      title: '획득 전 배지',
                      count: locked.length,
                      trailing: _filter == _Filter.locked
                          ? _FilterButton(value: _filter, onChanged: (f) => setState(() => _filter = f))
                          : null,
                    ),
                    if (_filter != _Filter.earned) _BadgeGrid(badges: locked, onTap: _open),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count, this.trailing, this.onLongPress});

  final String title;
  final int count;
  final Widget? trailing;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray04)),
      ),
      child: Row(
        children: [
          GestureDetector(onLongPress: onLongPress, child: CountTitle(title, '$count')),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

/// "전체 ⌄" 드롭다운(56×26, 굴곡 4, #EDEEF6 테두리).
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.value, required this.onChanged});

  final _Filter value;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Filter>(
      tooltip: '배지 보기 필터',
      initialValue: value,
      onSelected: onChanged,
      color: Colors.white,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (_) => [
        for (final f in _Filter.values)
          PopupMenuItem(
            value: f,
            height: 40,
            child: Text(
              f.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: f == value ? FontWeight.w600 : FontWeight.w500,
                color: f == value ? AppColors.brand : AppColors.gray07,
              ),
            ),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 26),
        padding: const EdgeInsets.only(left: 8, right: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray02),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.label,
              style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.gray07),
            ),
            const SizedBox(width: 2),
            const AxisIcon(KitIcon.chevronDownSmall, size: 14, color: AppColors.gray05),
          ],
        ),
      ),
    );
  }
}

/// 3칸씩 줄을 나누고 줄마다 아래 1px 선.
class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.badges, required this.onTap});

  final List<BadgeInfo> badges;
  final ValueChanged<BadgeInfo> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < badges.length; i += 3)
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray02)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = i; j < i + 3; j++)
                  Expanded(
                    child: j < badges.length
                        ? Semantics(
                            button: true,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(badges[j]),
                              child: Center(
                                child: AxisBadgeItem(
                                  medal: badges[j].medal,
                                  caption: badges[j].caption,
                                  progress: badges[j].progress,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
