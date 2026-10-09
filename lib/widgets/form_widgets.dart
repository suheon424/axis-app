import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// 상단 네비게이션(뒤로가기 + 가운데 제목, Bold 18 gray06).
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray06),
          ),
          // 아이콘은 왼쪽 14에 오고, 탭 영역(48)은 그 둘레로 넓힌다.
          const Positioned(left: 2, child: BackArrowButton()),
        ],
      ),
    );
  }
}

class BackArrowButton extends StatelessWidget {
  const BackArrowButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '뒤로',
      onPressed: () => Navigator.of(context).maybePop(),
      icon: SvgPicture.asset(
        'assets/icons/ic_arrow_left.svg',
        width: 24,
        height: 24,
        colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    );
  }
}

/// TextField 컴포넌트의 상태별 모양.
/// 빈 값: 라벨을 숨기고 라벨 문구를 placeholder로 / 입력 중: 파란 라벨·2px 밑줄 /
/// 값 있음: 회색 라벨·옅은 밑줄 / 오류: 빨간 라벨·2px 밑줄·도움말.
class _FieldFrame extends StatelessWidget {
  const _FieldFrame({
    required this.label,
    required this.showLabel,
    required this.labelColor,
    required this.lineColor,
    required this.lineWidth,
    required this.child,
    this.trailing,
    this.message,
    this.messageColor = AppColors.caption,
    this.onTap,
  });

  final String label;
  final bool showLabel;
  final Color labelColor;
  final Color lineColor;
  final double lineWidth;
  final Widget child;
  final Widget? trailing;
  final String? message;
  final Color messageColor;
  final VoidCallback? onTap;

  static const _anim = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: showLabel ? 1 : 0,
          duration: _anim,
          child: AnimatedDefaultTextStyle(
            duration: _anim,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              height: 1.4,
              letterSpacing: -0.26,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
            child: Text(label),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: _anim,
            height: 44,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: lineColor, width: lineWidth)),
            ),
            child: Row(
              children: [
                Expanded(child: child),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: _anim,
          alignment: Alignment.topLeft,
          child: message == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    message!,
                    style: TextStyle(fontSize: 13, height: 1.5, letterSpacing: -0.26, color: messageColor),
                  ),
                ),
        ),
      ],
    );
  }
}

const _valueStyle = TextStyle(
  fontSize: 17,
  height: 1.5,
  letterSpacing: -0.34,
  fontWeight: FontWeight.w500,
  color: AppColors.text,
);
const _placeholderStyle = TextStyle(
  fontSize: 17,
  height: 1.5,
  letterSpacing: -0.34,
  fontWeight: FontWeight.w400,
  color: AppColors.gray05,
);

/// 밑줄형 입력창(TextField). 값이 있으면 오른쪽에 지우기 버튼이 생긴다.
class AxisTextField extends StatefulWidget {
  const AxisTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.error,
    this.helper,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  /// 오류 문구. 있으면 빨간 오류 상태로 그린다.
  final String? error;

  /// 오류가 없을 때 아래에 보여 줄 도움말.
  final String? helper;

  @override
  State<AxisTextField> createState() => _AxisTextFieldState();
}

class _AxisTextFieldState extends State<AxisTextField> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_refresh);
    widget.controller.removeListener(_refresh);
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final hasValue = widget.controller.text.isNotEmpty;
    final error = widget.error;

    final Color labelColor;
    final Color lineColor;
    if (error != null) {
      labelColor = lineColor = AppColors.error;
    } else if (focused) {
      labelColor = lineColor = AppColors.primary;
    } else {
      labelColor = AppColors.gray06;
      lineColor = hasValue ? AppColors.line : AppColors.gray04;
    }

    return _FieldFrame(
      label: widget.label,
      showLabel: hasValue || focused || error != null,
      labelColor: labelColor,
      lineColor: lineColor,
      lineWidth: error != null || focused ? 2 : 1,
      message: error ?? widget.helper,
      messageColor: error != null ? AppColors.error : AppColors.caption,
      onTap: () => _focus.requestFocus(),
      trailing: hasValue
          ? Semantics(
              button: true,
              label: '${widget.label} 지우기',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.controller.clear,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset('assets/icons/ic_clear.svg', width: 18, height: 18),
                ),
              ),
            )
          : null,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        obscureText: widget.obscure,
        obscuringCharacter: '•',
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        style: _valueStyle,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: focused ? null : widget.label,
          hintStyle: _placeholderStyle,
        ),
      ),
    );
  }
}

/// 눌러서 시트·다른 화면에서 값을 고르는 선택형 입력창(오른쪽 아래 화살표).
class AxisSelectField extends StatelessWidget {
  const AxisSelectField({super.key, required this.label, required this.value, required this.onTap});

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Semantics(
      button: true,
      label: hasValue ? '$label, $value' : label,
      excludeSemantics: true,
      onTap: onTap,
      child: _FieldFrame(
        label: label,
        showLabel: hasValue,
        labelColor: AppColors.primary,
        lineColor: hasValue ? AppColors.primary : AppColors.gray04,
        lineWidth: 1,
        onTap: onTap,
        trailing: SvgPicture.asset('assets/icons/ic_chevron_down.svg', width: 18, height: 18),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              hasValue ? value! : label,
              key: ValueKey(hasValue ? value : ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: hasValue ? _valueStyle : _placeholderStyle,
            ),
          ),
        ),
      ),
    );
  }
}

/// 22px 체크박스(Checkbox/Off · Checkbox/On).
class AxisCheckbox extends StatelessWidget {
  const AxisCheckbox({super.key, required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: checked ? null : Border.all(color: AppColors.checkboxBorder, width: 1.5),
      ),
      child: AnimatedScale(
        scale: checked ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: SvgPicture.asset('assets/icons/ic_check.svg', width: 22, height: 22),
      ),
    );
  }
}

/// 약관 동의 한 줄(Consent). [bold]는 "전체 동의"용, [onView]가 있으면 오른쪽에 "보기"가 붙는다.
class ConsentRow extends StatelessWidget {
  const ConsentRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
    this.bold = false,
    this.onView,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool bold;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            checked: checked,
            label: label,
            excludeSemantics: true,
            onTap: () => onChanged(!checked),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(!checked),
              child: Row(
                children: [
                  AxisCheckbox(checked: checked),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: bold
                          ? const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray07)
                          : const TextStyle(fontSize: 14, color: AppColors.body),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onView != null)
          GestureDetector(
            onTap: onView,
            child: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '보기',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.caption,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.caption,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 시트 안의 사각 선택 상자(준비시간 칩, MBTI 옵션). 선택되면 연파랑 배경 + 파란 테두리.
class OptionBox extends StatelessWidget {
  const OptionBox({super.key, required this.selected, required this.onTap, required this.child, this.label});

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.blue01 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.primary : AppColors.chipBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
