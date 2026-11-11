import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_data.dart';
import 'my_widgets.dart';
import 'point_shop_screen.dart';

/// 12-2 포인트 내역(130:13052): 파란 보유 포인트 카드 + 전체·적립·사용 칩 + 날짜별 내역.
/// 내역이 없으면 빈 상태(130:14531). 데모: 카드를 길게 누르면 빈 상태로 바뀐다.
class PointHistoryScreen extends StatefulWidget {
  const PointHistoryScreen({super.key, this.entries = samplePointEntries});

  final List<PointEntry> entries;

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  static const _filters = ['전체', '적립', '사용'];
  int _filter = 0;
  late List<PointEntry> _entries = widget.entries;

  List<PointEntry> get _visible => switch (_filter) {
    1 => _entries.where((e) => e.amount > 0).toList(),
    2 => _entries.where((e) => e.amount < 0).toList(),
    _ => _entries,
  };

  @override
  Widget build(BuildContext context) {
    final balance = _entries.isEmpty ? 0 : myProfile.value.points;
    final visible = _visible;
    return MySubScaffold(
      title: '포인트',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          GestureDetector(
            onLongPress: () => setState(() => _entries = _entries.isEmpty ? widget.entries : const []),
            child: _BalanceCard(
              points: balance,
              onUse: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PointShopScreen())),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray05)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < _filters.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  _FilterChip(label: _filters[i], selected: i == _filter, onTap: () => setState(() => _filter = i)),
                ],
              ],
            ),
          ),
          if (visible.isEmpty)
            MyEmptyState(
              icon: KitIcon.statePoint,
              title: '아직 포인트 내역이 없어요',
              description: '출석 체크와 이벤트에 참여하고\n포인트를 모아보세요.',
              actionLabel: '이벤트 보러 가기',
              outline: true,
              onAction: () => MainTabRouter.open(context, MainTab.event),
            )
          else
            for (var i = 0; i < visible.length; i++) ...[
              if (i == 0 || visible[i - 1].date != visible[i].date)
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 4),
                  child: Text(visible[i].date, style: AxisText.groupLabel),
                ),
              _PointRow(entry: visible[i]),
            ],
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.points, required this.onUse});

  final int points;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [AppColors.brand, Color(0xFF136BFF)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '보유 포인트',
            style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.blue01),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatPoints(points)}P',
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1.3,
                    letterSpacing: -0.56,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              PressBuilder(
                semanticLabel: '사용하기',
                onTap: onUse,
                builder: (_, pressed) => Container(
                  constraints: const BoxConstraints(minHeight: 28),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: pressed ? AppColors.brandSoft : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '사용하기',
                    style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.brand),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 전체·적립·사용 칩(선택: 검정 채움 / 나머지: 흰 바탕 + #DDDFEA 테두리).
class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minWidth: 56, minHeight: 24),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
          decoration: BoxDecoration(
            color: selected ? AppColors.text : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.text : AppColors.chipBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.neutralText,
            ),
          ),
        ),
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({required this.entry});

  final PointEntry entry;

  @override
  Widget build(BuildContext context) {
    final plus = entry.amount > 0;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray02)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 2),
                Text('${entry.source} · ${entry.time}', style: AxisText.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${plus ? '+' : ''}${formatPoints(entry.amount)}P',
                style: AxisText.rowTitle.copyWith(color: plus ? AppColors.brand : AppColors.text),
              ),
              const SizedBox(height: 2),
              Text('${formatPoints(entry.balance)}P', style: AxisText.caption),
            ],
          ),
        ],
      ),
    );
  }
}
