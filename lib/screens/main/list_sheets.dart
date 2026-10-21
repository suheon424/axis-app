import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import 'list_data.dart';
import 'list_parts.dart';

/// 07_08 일정 상세 시트에서 고른 행동.
enum ListSheetAction { edit, changeDate, delete }

/// 07_08 일정 상세 시트(더보기 → 07_08-1 메뉴). 고른 행동을 돌려준다.
Future<ListSheetAction?> showListDetailSheet(BuildContext context, ListSchedule item) {
  return showModalBottomSheet<ListSheetAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x66000000),
    isScrollControlled: true,
    builder: (_) => ListDetailSheet(item: item),
  );
}

class ListDetailSheet extends StatefulWidget {
  const ListDetailSheet({super.key, required this.item});

  final ListSchedule item;

  @override
  State<ListDetailSheet> createState() => _ListDetailSheetState();
}

class _ListDetailSheetState extends State<ListDetailSheet> {
  bool _menuOpen = false;

  void _close([ListSheetAction? action]) => Navigator.of(context).pop(action);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, -4))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 34 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFD0D4DB), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 32,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray07),
                        ),
                      ),
                      _SheetIcon(
                        asset: 'assets/icons/list_more.svg',
                        label: '더보기',
                        onTap: () => setState(() => _menuOpen = !_menuOpen),
                      ),
                      const SizedBox(width: 4),
                      _SheetIcon(asset: 'assets/icons/ic_close.svg', label: '닫기', onTap: _close),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _InfoRow(icon: 'assets/icons/list_clock.svg', text: item.timeRange),
                const SizedBox(height: 12),
                _InfoRow(icon: 'assets/icons/list_pin.svg', text: item.place, sub: item.address),
                const SizedBox(height: 12),
                _InfoRow(icon: 'assets/icons/list_repeat.svg', text: item.repeat),
                const SizedBox(height: 16),
                BrandButton(label: '수정하기', onPressed: () => _close(ListSheetAction.edit)),
              ],
            ),
          ),
          // 더보기 메뉴 바깥을 누르면 메뉴만 닫는다.
          if (_menuOpen)
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _menuOpen = false)),
            ),
          Positioned(
            top: 58,
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
                    width: 162,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 20, offset: Offset(0, 6))],
                    ),
                    child: Column(
                      children: [
                        _MenuItem(label: '날짜 변경', onTap: () => _close(ListSheetAction.changeDate)),
                        _MenuItem(label: '삭제', color: CubeColors.red, onTap: () => _close(ListSheetAction.delete)),
                      ],
                    ),
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

class _SheetIcon extends StatelessWidget {
  const _SheetIcon({required this.asset, required this.label, required this.onTap});

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(dimension: 32, child: Center(child: SvgPicture.asset(asset, width: 24, height: 24))),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.sub});

  final String icon;
  final String text;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 18, height: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.gray07),
        ),
        if (sub != null) ...[
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              sub!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8B95A1)),
            ),
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
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
          ),
        ),
      ),
    );
  }
}

/// 07_08-2 삭제 확인에서 고른 범위.
enum ListDeleteScope { onlyThis, allFollowing }

Future<ListDeleteScope?> showListDeleteDialog(BuildContext context) {
  return showDialog<ListDeleteScope>(
    context: context,
    barrierColor: const Color(0x66000000),
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 310,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '일정을 삭제할까요?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray07),
              ),
              const SizedBox(height: 8),
              const Text('삭제한 일정은 되돌릴 수 없어요.', style: TextStyle(fontSize: 14, color: AppColors.body)),
              const SizedBox(height: 20),
              _DialogButton(
                label: '이 일정만 삭제',
                background: CubeColors.red,
                color: Colors.white,
                onTap: () => Navigator.of(context).pop(ListDeleteScope.onlyThis),
              ),
              const SizedBox(height: 8),
              _DialogButton(
                label: '이후 모든 일정 삭제',
                border: const Color(0xFFF5C2C3),
                color: CubeColors.red,
                onTap: () => Navigator.of(context).pop(ListDeleteScope.allFollowing),
              ),
              const SizedBox(height: 8),
              _DialogButton(
                label: '취소',
                border: AppColors.chipBorder,
                color: const Color(0xFF4E5968),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.background = Colors.white,
    this.border,
  });

  final String label;
  final Color color;
  final Color background;
  final Color? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 12.5),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: border == null ? null : Border.all(color: border!),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ),
    );
  }
}

/// pop_07_05: 오늘 일정 6개를 모두 체크하면 뜨는 "중심의 첫걸음" 배지 획득 팝업.
Future<void> showListBadgePopup(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '닫기',
    barrierColor: const Color(0xB8000000),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, _, _) => const ListBadgePopup(),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

class ListBadgePopup extends StatefulWidget {
  const ListBadgePopup({super.key});

  @override
  State<ListBadgePopup> createState() => _ListBadgePopupState();
}

class _ListBadgePopupState extends State<ListBadgePopup> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: 310,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: AppColors.blue01),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment(0.003, -0.443),
                                radius: 0.56,
                                colors: [
                                  Color(0xFF0057ED),
                                  Color(0xF01061EE),
                                  Color(0xDF206CEF),
                                  Color(0xBF4081F1),
                                  Color(0x8080ABF6),
                                  Color(0x00FFFFFF),
                                ],
                                stops: [0, 0.0625, 0.125, 0.25, 0.5, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(43, 0, 43, 24),
                        child: Column(
                          children: [
                            Image.asset('assets/images/main/list_badge_first_step.png', width: 224, height: 224),
                            const SizedBox(height: 15),
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: '축하드립니다!\n'),
                                  TextSpan(
                                    text: '중심의 첫걸음\n',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                  TextSpan(text: '배지를 획득했어요'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.3,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              '누적 완료 6회 이상',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray07),
                            ),
                            const SizedBox(height: 22),
                            Semantics(
                              button: true,
                              label: '칭호로 등록하기',
                              excludeSemantics: true,
                              onTap: () => _register(context),
                              child: Pressable(
                                onTap: () => _register(context),
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 9.6, vertical: 4.5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '칭호로 등록하기',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: ListIconButton(
                          asset: 'assets/icons/ic_close.svg',
                          label: '닫기',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Semantics(
                button: true,
                label: '이미지 저장',
                excludeSemantics: true,
                onTap: () => _save(context),
                child: Pressable(
                  onTap: () => _save(context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_saved)
                          const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        else
                          SvgPicture.asset('assets/icons/list_download.svg', width: 18, height: 18),
                        const SizedBox(width: 8),
                        Text(
                          _saved ? '저장했어요' : '이미지 저장',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
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

  void _register(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('‘중심의 첫걸음’을 칭호로 등록했어요.')));
  }

  void _save(BuildContext context) => setState(() => _saved = true);
}
