import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';
import 'kit_buttons.dart';

/// Sheet/Header(130:9841) · Sheet/Header + More(130:9891) · Sheet/Header AI(130:9896).
/// 제목(20 Bold) + (더보기 ⋯) + 닫기 X. [ai]면 파란 그라디언트 제목 + 반짝이 아이콘.
class AxisSheetHeader extends StatelessWidget {
  const AxisSheetHeader({super.key, required this.title, this.onClose, this.onMore, this.ai = false});

  final String title;

  /// 없으면 Navigator.maybePop.
  final VoidCallback? onClose;

  /// 있으면 닫기 앞에 ⋯ 버튼이 붙는다.
  final VoidCallback? onMore;
  final bool ai;

  @override
  Widget build(BuildContext context) {
    Widget text = Text(title, style: AxisText.sectionTitle.copyWith(color: ai ? Colors.white : null));
    if (ai) {
      text = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => const LinearGradient(colors: [AppColors.brand, Color(0xFF4AA3FF)]).createShader(r),
        child: text,
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: Row(
        children: [
          if (ai) ...[const AxisIcon(KitIcon.aiSparkle, size: 22), const SizedBox(width: 4)],
          Expanded(child: text),
          if (onMore != null) ...[
            AxisIconButton(icon: KitIcon.navMore, tooltip: '더보기', onPressed: onMore),
            const SizedBox(width: 4),
          ],
          AxisCloseButton(onPressed: onClose),
        ],
      ),
    );
  }
}

/// 공통 바텀시트(흰 바탕, 위 굴곡 16, 좌우 20). 높이는 내용에 맞추고 화면의 90%를 넘지 않는다.
/// [title]이 있으면 [AxisSheetHeader]를 위에 둔다. [footer]는 아래 고정(예: AxisCtaButton).
/// 시트에서 Navigator.pop(context, 값)으로 돌려준 값을 받는다.
Future<T?> showAxisSheet<T>(
  BuildContext context, {
  String? title,
  bool ai = false,
  VoidCallback? onMore,
  required WidgetBuilder builder,
  WidgetBuilder? footer,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    elevation: 0,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 320),
      reverseDuration: Duration(milliseconds: 240),
    ),
    builder: (ctx) => AxisSheetFrame(
      header: title == null ? null : AxisSheetHeader(title: title, ai: ai, onMore: onMore),
      footer: footer?.call(ctx),
      child: builder(ctx),
    ),
  );
}

/// [showAxisSheet]의 틀. 직접 쓸 때는 showModalBottomSheet(backgroundColor: transparent)의 builder 안에 둔다.
class AxisSheetFrame extends StatelessWidget {
  const AxisSheetFrame({super.key, this.header, required this.child, this.footer});

  final Widget? header;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final safeBottom = mq.padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(color: Color(0x1F000000), offset: Offset(0, -4), blurRadius: 24)],
          ),
          padding: EdgeInsets.fromLTRB(20, 22, 20, (safeBottom > 20 ? safeBottom : 20) + 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[header!, const SizedBox(height: 16)],
              Flexible(child: SingleChildScrollView(child: child)),
              if (footer != null) ...[const SizedBox(height: 20), footer!],
            ],
          ),
        ),
      ),
    );
  }
}
