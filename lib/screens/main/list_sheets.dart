import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';
import 'list_data.dart';

/// 07_08 일정 상세 시트에서 고른 행동.
enum ListSheetAction { edit, changeDate, delete }

/// 07_08 일정 상세 시트(⋯ → 07_08-1 더보기 메뉴). 고른 행동을 돌려준다.
Future<ListSheetAction?> showListDetailSheet(BuildContext context, ListSchedule item) {
  return showModalBottomSheet<ListSheetAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    elevation: 0,
    builder: (_) => ListDetailSheet(item: item),
  );
}

class ListDetailSheet extends StatefulWidget {
  const ListDetailSheet({super.key, required this.item, this.initialMenuOpen = false});

  final ListSchedule item;

  /// 처음부터 더보기 메뉴를 펼친 채로(07_08-1 확인용).
  final bool initialMenuOpen;

  @override
  State<ListDetailSheet> createState() => _ListDetailSheetState();
}

class _ListDetailSheetState extends State<ListDetailSheet> {
  late bool _menuOpen = widget.initialMenuOpen;

  void _close([ListSheetAction? action]) => Navigator.of(context).pop(action);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Stack(
      children: [
        AxisSheetFrame(
          header: AxisSheetHeader(
            title: item.title,
            onMore: () => setState(() => _menuOpen = !_menuOpen),
            onClose: _close,
          ),
          footer: AxisCtaButton(label: '일정 수정', onPressed: () => _close(ListSheetAction.edit)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(icon: 'assets/icons/list_clock.svg', text: item.timeRange),
              const SizedBox(height: 11),
              _InfoRow(icon: 'assets/icons/list_pin.svg', text: item.place, sub: item.address),
              const SizedBox(height: 11),
              _InfoRow(icon: 'assets/icons/list_repeat.svg', text: item.repeat),
            ],
          ),
        ),
        // 더보기 메뉴 바깥을 누르면 메뉴만 닫는다.
        if (_menuOpen)
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _menuOpen = false)),
          ),
        Positioned(
          top: 52,
          right: 22,
          child: IgnorePointer(
            ignoring: !_menuOpen,
            child: AnimatedOpacity(
              opacity: _menuOpen ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: AnimatedScale(
                scale: _menuOpen ? 1 : 0.92,
                alignment: Alignment.topRight,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray02),
                    boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MenuItem(label: '날짜 변경', onTap: () => _close(ListSheetAction.changeDate)),
                      _MenuItem(label: '삭제', color: AppColors.error, onTap: () => _close(ListSheetAction.delete)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 아이콘(20, gray06) + 16 Medium 값 + (선택) 12 회색 보조.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.sub});

  final String icon;
  final String text;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(AppColors.gray06, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500, color: AppColors.gray07),
          ),
        ),
        if (sub != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(sub!, overflow: TextOverflow.ellipsis, style: AxisText.caption),
          ),
        ],
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.label, required this.onTap, this.color = AppColors.gray07});

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: label,
      onTap: onTap,
      scale: 1,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 44),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        color: pressed ? AppColors.gray01 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Text(
          label,
          style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: color),
        ),
      ),
    );
  }
}

/// 07_08-2 삭제 확인에서 고른 범위.
enum ListDeleteScope { onlyThis, allFollowing }

/// 07_08-2 삭제 확인(Dialog/Confirm 빨강). X나 바깥을 누르면 null.
Future<ListDeleteScope?> showListDeleteDialog(BuildContext context) async {
  final ok = await showAxisConfirm(
    context,
    title: '일정을 삭제할까요?',
    message: '삭제한 일정은 되돌릴 수 없어요.',
    confirmLabel: '이 일정만 삭제',
    otherLabel: '이후 일정 삭제',
  );
  return switch (ok) {
    true => ListDeleteScope.onlyThis,
    false => ListDeleteScope.allFollowing,
    null => null,
  };
}
