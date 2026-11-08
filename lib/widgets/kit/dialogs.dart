import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';
import 'kit_buttons.dart';

/// Dialog/Confirm(130:9948): 흰 상자(폭 320, 굴곡 12) — 제목(18 Bold) + 닫기, 설명(14), 사선 버튼 쌍.
/// [destructive]면 빨강(왼쪽 채움=[confirmLabel], 오른쪽 테두리=[otherLabel]),
/// 아니면 파랑(왼쪽 회색=[otherLabel], 오른쪽 파랑=[confirmLabel]).
class AxisConfirmDialog extends StatelessWidget {
  const AxisConfirmDialog({
    super.key,
    required this.title,
    this.message,
    required this.confirmLabel,
    required this.otherLabel,
    this.destructive = true,
    required this.onConfirm,
    required this.onOther,
    this.onClose,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String otherLabel;
  final bool destructive;
  final VoidCallback onConfirm;
  final VoidCallback onOther;

  /// 닫기(X). null이면 Navigator.maybePop.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: AxisText.title18.copyWith(color: AppColors.gray07)),
              ),
              AxisCloseButton(onPressed: onClose),
            ],
          ),
          if (message != null) Text(message!, style: AxisText.body),
          const SizedBox(height: 16),
          destructive
              ? AxisSplitButton(
                  tone: AxisSplitTone.red,
                  leftLabel: confirmLabel,
                  rightLabel: otherLabel,
                  onLeft: onConfirm,
                  onRight: onOther,
                )
              : AxisSplitButton(
                  height: 40,
                  leftLabel: otherLabel,
                  rightLabel: confirmLabel,
                  onLeft: onOther,
                  onRight: onConfirm,
                ),
        ],
      ),
    );
  }
}

/// [AxisConfirmDialog]를 띄운다. [confirmLabel]을 누르면 true, [otherLabel]을 누르면 false,
/// 닫기(X)·바깥을 누르면 null.
Future<bool?> showAxisConfirm(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  String otherLabel = '취소',
  bool destructive = true,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '닫기',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, _) => Center(
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AxisConfirmDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            otherLabel: otherLabel,
            destructive: destructive,
            onConfirm: () => Navigator.of(ctx).pop(true),
            onOther: () => Navigator.of(ctx).pop(false),
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    ),
    transitionBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

/// Toast(130:10255): 어두운 알약(gray07 95%, 굴곡 12) — 파란 체크 + 문구(14 Medium 흰색) + 선택 행동(하늘색).
class AxisToast extends StatelessWidget {
  const AxisToast({super.key, required this.message, this.actionLabel, this.onAction, this.showCheck = true});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.toastBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x29000000), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          if (showCheck) ...[
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: AppColors.brandStep, shape: BoxShape.circle),
              child: const AxisIcon(KitIcon.checkWhite, size: 20),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.toastAction,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

OverlayEntry? _toastEntry;
Timer? _toastTimer;

/// 화면 아래에 [AxisToast]를 [duration] 동안 띄운다. 이미 떠 있는 토스트는 바로 바꾼다.
/// [bottom]은 안전 영역 위 여백(탭 바가 있는 화면은 탭 바 높이 + 12 정도, 예: 82).
void showAxisToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 2),
  double bottom = 24,
}) {
  hideAxisToast();
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: 20,
      right: 20,
      // 피그마 프레임은 늘 34 Home Indicator를 둔다. 웹처럼 아래 여백이 0이어도 탭 바(92) 위에 뜨도록 34로 맞춘다.
      bottom: math.max(MediaQuery.paddingOf(ctx).bottom, 34) + bottom,
      child: _ToastAnimator(
        child: Material(
          type: MaterialType.transparency,
          child: AxisToast(
            message: message,
            actionLabel: actionLabel,
            onAction: onAction == null
                ? null
                : () {
                    hideAxisToast();
                    onAction();
                  },
          ),
        ),
      ),
    ),
  );
  _toastEntry = entry;
  overlay.insert(entry);
  _toastTimer = Timer(duration, () {
    if (_toastEntry == entry) hideAxisToast();
  });
}

/// 떠 있는 토스트를 닫는다.
void hideAxisToast() {
  _toastTimer?.cancel();
  _toastTimer = null;
  _toastEntry?.remove();
  _toastEntry = null;
}

class _ToastAnimator extends StatefulWidget {
  const _ToastAnimator({required this.child});

  final Widget child;

  @override
  State<_ToastAnimator> createState() => _ToastAnimatorState();
}

class _ToastAnimatorState extends State<_ToastAnimator> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(curved),
        child: widget.child,
      ),
    );
  }
}
