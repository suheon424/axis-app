import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'kit_buttons.dart';

/// More Menu(07_08-1 더보기 메뉴 130:11190)의 한 줄.
class AxisMoreMenuItem<T> {
  const AxisMoreMenuItem({required this.label, required this.value, this.danger = false});

  final String label;
  final T value;

  /// 빨간 글자(삭제 등).
  final bool danger;
}

/// More Menu 상자: 흰 바탕, #E4E7EC 1px 선, 굴곡 12, 그림자(검정 14%, y6, 흐림 20), 폭 162.
/// 줄은 높이 48, 좌우 16, 16 Medium(줄 높이 150%).
class AxisMoreMenu<T> extends StatelessWidget {
  const AxisMoreMenu({super.key, required this.items, required this.onSelected});

  final List<AxisMoreMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  static const width = 162.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 20, offset: Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [for (final item in items) _Row(item: item, onTap: () => onSelected(item.value))],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onTap});

  final AxisMoreMenuItem<dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: item.label,
      onTap: onTap,
      scale: 1,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        color: pressed ? AppColors.gray01 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          item.label,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: item.danger ? const Color(0xFFE00000) : AppColors.gray07,
          ),
        ),
      ),
    );
  }
}

/// [anchor] 버튼 아래 오른쪽 끝에 맞춰 More Menu를 띄운다. 바깥을 누르면 null.
Future<T?> showAxisMoreMenu<T>(BuildContext anchor, {required List<AxisMoreMenuItem<T>> items}) {
  final box = anchor.findRenderObject()! as RenderBox;
  final overlay = Navigator.of(anchor).overlay!.context.findRenderObject()! as RenderBox;
  final rect = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  return showGeneralDialog<T>(
    context: anchor,
    barrierDismissible: true,
    barrierLabel: '닫기',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (ctx, _, _) {
      final screen = overlay.size;
      final right = (screen.width - rect.right).clamp(8.0, screen.width - AxisMoreMenu.width - 8);
      // 메뉴가 아래로 넘치면 버튼 위로 연다.
      final below = rect.bottom + 4 + items.length * 48 + 2 < screen.height - 24;
      return Stack(
        children: [
          Positioned(
            right: right,
            top: below ? rect.bottom + 4 : null,
            bottom: below ? null : screen.height - rect.top + 4,
            // 대화 창 안에는 Material이 없어 글자 밑줄이 생기지 않게 감싼다.
            child: Material(
              type: MaterialType.transparency,
              child: AxisMoreMenu<T>(items: items, onSelected: (v) => Navigator.pop(ctx, v)),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (ctx, a, _, child) => FadeTransition(
      opacity: a,
      child: ScaleTransition(
        scale: Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
        alignment: Alignment.topRight,
        child: child,
      ),
    ),
  );
}
