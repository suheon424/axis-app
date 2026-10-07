import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// 상단 네비게이션(뒤로가기 + 가운데 제목). Figma 프로토타입의 유일한 인터랙션인 "Back"을 그대로 연결한다.
class AxisNavBar extends StatelessWidget {
  const AxisNavBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.navHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w600, color: AppColors.gray09),
          ),
          Positioned(left: 4, child: const BackArrowButton()),
        ],
      ),
    );
  }
}

class BackArrowButton extends StatelessWidget {
  const BackArrowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '뒤로',
      onPressed: () => Navigator.of(context).maybePop(),
      icon: SvgPicture.asset('assets/icons/ic_arrow_left.svg', width: 24, height: 24),
    );
  }
}

/// 굵은 라벨 + 밑줄 입력창. 입력 중이거나 값이 있으면 밑줄과 글자가 파란색(03 화면)으로 바뀐다.
class LabeledUnderlineField extends StatefulWidget {
  const LabeledUnderlineField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.value,
    this.labelStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gray07),
    this.hintColor = AppColors.gray04,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  /// 읽기 전용(선택형) 필드일 때 탭 동작.
  final VoidCallback? onTap;
  final bool readOnly;

  /// 읽기 전용 필드에 표시할 선택값.
  final String? value;
  final TextStyle labelStyle;
  final Color hintColor;

  @override
  State<LabeledUnderlineField> createState() => _LabeledUnderlineFieldState();
}

class _LabeledUnderlineFieldState extends State<LabeledUnderlineField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    widget.controller?.addListener(_onText);
  }

  void _onText() => setState(() {});

  @override
  void dispose() {
    widget.controller?.removeListener(_onText);
    _focus.dispose();
    super.dispose();
  }

  bool get _active {
    if (widget.readOnly) return (widget.value ?? '').isNotEmpty;
    return _focus.hasFocus || (widget.controller?.text.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    const activeText = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary);

    final Widget field = widget.readOnly
        ? Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                active ? widget.value! : widget.hint,
                key: ValueKey(active ? widget.value : ''),
                style: active ? activeText : TextStyle(fontSize: 14, color: widget.hintColor),
              ),
            ),
          )
        : TextField(
            controller: widget.controller,
            focusNode: _focus,
            obscureText: widget.obscure,
            obscuringCharacter: '*',
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            style: activeText,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: widget.hint,
              hintStyle: TextStyle(fontSize: 14, color: widget.hintColor, fontWeight: FontWeight.w400),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: widget.labelStyle),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.readOnly ? widget.onTap : () => _focus.requestFocus(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: AppSizes.buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: active ? AppColors.primary : AppColors.gray05,
                  width: active ? 2 : 1,
                ),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: field,
          ),
        ),
      ],
    );
  }
}

/// 약관 동의 체크박스 한 줄.
class AgreementCheck extends StatelessWidget {
  const AgreementCheck({super.key, required this.label, required this.checked, required this.onChanged});

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!checked),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: checked ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: checked ? AppColors.primary : AppColors.muted),
              ),
              child: AnimatedScale(
                scale: checked ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: const CustomPaint(painter: _CheckPainter()),
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Figma 체크 표시 경로: M5.5 9 L8 11.5 L12.5 6.5 (18x18 기준)
    final s = size.width / 18;
    final path = Path()
      ..moveTo(5.5 * s, 9 * s)
      ..lineTo(8 * s, 11.5 * s)
      ..lineTo(12.5 * s, 6.5 * s);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 시트 안의 둥근 선택 칩. 선택되면 파란 배경으로 바뀐다(09 화면의 ESFP).
class SelectChip extends StatelessWidget {
  const SelectChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 39,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: selected ? AppColors.primary : AppColors.chipBorder),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              height: 21 / 16,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.gray06,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.visible, softWrap: false),
          ),
        ),
      ),
    );
  }
}
