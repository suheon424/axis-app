import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_data.dart';
import 'my_widgets.dart';

/// 포인트 상점 상품 하나.
class ShopItem {
  const ShopItem(this.id, this.group, this.title, this.detail, this.price);

  final String id;

  /// 0 = axis 꾸미기, 1 = 기프티콘.
  final int group;
  final String title;
  final String detail;
  final int price;
}

const shopItems = [
  ShopItem('theme_dawn', 0, '테마 ‘새벽 블루’', '홈 배경 테마', 500),
  ShopItem('theme_aurora', 0, '테마 ‘오로라 그린’', '홈 배경 테마', 500),
  ShopItem('theme_sunset', 0, '테마 ‘노을 퍼플’', '홈 배경 테마', 500),
  ShopItem('outfit_hood', 0, '캐릭터 의상 ‘후드 집업’', '프로필 캐릭터 꾸미기', 800),
  ShopItem('cu_1000', 1, 'CU 모바일 상품권 1,000원', '유효기간 30일', 1000),
  ShopItem('mega_americano', 1, '메가커피 아이스 아메리카노', '유효기간 30일', 2000),
  ShopItem('starbucks_t', 1, '스타벅스 아메리카노 T', '유효기간 30일', 4500),
];

/// 이미 가진 꾸미기 상품(새벽 블루 테마는 포인트 내역에 구매 기록이 있다).
final ownedShopItems = ValueNotifier<Set<String>>({'theme_dawn'});

/// 12-2-1 마이 · 포인트 상점(205:10535): 12-2 포인트의 "사용하기"로 들어온다.
/// 파란 보유 포인트 카드(내역 보기) + 전체·꾸미기·기프티콘 칩 + 묶음별 상품 줄.
/// 상품 오른쪽은 가격과 상태(보유 중 · 교환하기 · N P 부족). 교환하기를 누르면 확인 후 포인트가 줄어든다.
class PointShopScreen extends StatefulWidget {
  const PointShopScreen({super.key});

  @override
  State<PointShopScreen> createState() => _PointShopScreenState();
}

class _PointShopScreenState extends State<PointShopScreen> {
  static const _filters = ['전체', '꾸미기', '기프티콘'];
  static const _groups = ['axis 꾸미기', '기프티콘'];
  int _filter = 0;

  Future<void> _exchange(ShopItem item) async {
    final ok = await showAxisConfirm(
      context,
      title: '${item.title}을(를) 교환할까요?',
      message: '${formatPoints(item.price)}P가 사용돼요.',
      confirmLabel: '교환하기',
      destructive: false,
    );
    if (ok != true || !mounted) return;
    final profile = myProfile.value;
    myProfile.value = profile.copyWith(points: profile.points - item.price);
    if (item.group == 0) ownedShopItems.value = {...ownedShopItems.value, item.id};
    showAxisToast(context, item.group == 0 ? '교환했어요. 바로 적용할 수 있어요.' : '교환했어요. 기프티콘은 알림으로 보내 드려요.');
  }

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: '포인트 상점',
      body: ListenableBuilder(
        listenable: Listenable.merge([myProfile, ownedShopItems]),
        builder: (context, _) {
          final points = myProfile.value.points;
          final owned = ownedShopItems.value;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            children: [
              _ShopBalanceCard(points: points, onHistory: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 19),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.gray05)),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < _filters.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      _ShopChip(label: _filters[i], selected: i == _filter, onTap: () => setState(() => _filter = i)),
                    ],
                  ],
                ),
              ),
              for (var g = 0; g < _groups.length; g++)
                if (_filter == 0 || _filter == g + 1) ...[
                  const SizedBox(height: 20),
                  Text(_groups[g], style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray06)),
                  const SizedBox(height: 10),
                  for (final (i, item) in shopItems.where((e) => e.group == g).indexed)
                    _ShopRow(
                      item: item,
                      owned: owned.contains(item.id),
                      points: points,
                      divider: i < shopItems.where((e) => e.group == g).length - 1,
                      onExchange: () => _exchange(item),
                    ),
                ],
            ],
          );
        },
      ),
    );
  }
}

/// balance: 350 · 굴곡 16 · #004FED → #136BFF. "보유 포인트" + 28 Bold 금액 + 흰 "내역 보기"(굴곡 6).
class _ShopBalanceCard extends StatelessWidget {
  const _ShopBalanceCard({required this.points, required this.onHistory});

  final int points;
  final VoidCallback onHistory;

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
                semanticLabel: '내역 보기',
                onTap: onHistory,
                builder: (_, pressed) => Container(
                  constraints: const BoxConstraints(minHeight: 25),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: pressed ? AppColors.brandSoft : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '내역 보기',
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

/// chip/…: 높이 24 · 굴곡 6 · 좌우 16.
class _ShopChip extends StatelessWidget {
  const _ShopChip({required this.label, required this.selected, required this.onTap});

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
          constraints: const BoxConstraints(minHeight: 24),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.text : Colors.white,
            borderRadius: BorderRadius.circular(6),
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

/// shop/…: 높이 64 · 제목 16 SemiBold · 설명 12 gray06 · 오른쪽 가격 + 상태 · 아래 1px 선.
class _ShopRow extends StatelessWidget {
  const _ShopRow({
    required this.item,
    required this.owned,
    required this.points,
    required this.divider,
    required this.onExchange,
  });

  final ShopItem item;
  final bool owned;
  final int points;
  final bool divider;
  final VoidCallback onExchange;

  @override
  Widget build(BuildContext context) {
    final short = item.price - points;
    final canBuy = !owned && short <= 0;
    final status = owned
        ? '보유 중'
        : short > 0
        ? '${formatPoints(short)}P 부족'
        : '교환하기';
    final row = Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.only(top: 10, bottom: 9),
      decoration: BoxDecoration(
        border: divider ? const Border(bottom: BorderSide(color: AppColors.gray02)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 3),
                Text(item.detail, style: AxisText.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${formatPoints(item.price)}P', style: AxisText.rowTitle.copyWith(color: AppColors.text)),
              const SizedBox(height: 3),
              Text(
                status,
                style: TextStyle(fontSize: 12, height: 1.4, color: canBuy ? AppColors.brand : AppColors.gray05),
              ),
            ],
          ),
        ],
      ),
    );
    if (!canBuy) return Semantics(label: '${item.title} ${formatPoints(item.price)}P, $status', child: row);
    return PressBuilder(
      semanticLabel: '${item.title} ${formatPoints(item.price)}P 교환하기',
      scale: 1,
      onTap: onExchange,
      builder: (_, _) => row,
    );
  }
}
