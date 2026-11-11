import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import 'kit/icons.dart';

/// Nav/Title(130:9407): 뒤로가기 + 가운데 제목(18 Bold gray06), 상태바 바로 아래 높이 50.
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
          Text(title, style: AxisText.navTitle),
          // 아이콘은 왼쪽 14에 오고, 탭 영역(48)은 그 둘레로 넓힌다.
          Positioned(
            left: 2,
            child: IconButton(
              tooltip: '뒤로',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const AxisIcon(KitIcon.navBack),
            ),
          ),
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

/// TextField(130:9234) 컴포넌트의 상태별 모양. 라벨 12 / 값 16 / 영역 44 / 도움말 12.
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
              fontSize: 12,
              height: 1.36,
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
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: lineColor, width: lineWidth),
              ),
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
                  child: Text(message!, style: TextStyle(fontSize: 12, height: 1.4, color: messageColor)),
                ),
        ),
      ],
    );
  }
}

const _valueStyle = TextStyle(
  fontSize: 16,
  height: 1.5,
  letterSpacing: -0.32,
  fontWeight: FontWeight.w500,
  color: AppColors.text,
);
const _placeholderStyle = TextStyle(
  fontSize: 16,
  height: 1.5,
  letterSpacing: -0.32,
  fontWeight: FontWeight.w500,
  color: AppColors.gray05,
);

/// 빈 칸의 밑줄(#BDC3D0)과 값이 있는 칸의 라벨(#636C78).
const _idleLine = AppColors.gray04;
const _filledLabel = AppColors.gray06;

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
    this.placeholderColor = AppColors.gray05,
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

  /// 빈 칸에 보이는 라벨 문구(placeholder) 색. 로그인 화면은 더 옅은 gray04.
  final Color placeholderColor;

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
      labelColor = lineColor = AppColors.brand;
    } else {
      labelColor = _filledLabel;
      lineColor = hasValue ? AppColors.line : _idleLine;
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
          hintStyle: _placeholderStyle.copyWith(color: widget.placeholderColor),
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
        labelColor: AppColors.brand,
        lineColor: hasValue ? AppColors.brand : _idleLine,
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

/// Checkbox(130:9292) 22px. On: 파랑 채움 + 흰 체크 / Off: 흰 채움 + #B8BEC8 1.5 테두리.
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
        color: checked ? AppColors.brand : Colors.white,
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

/// Agreement(130:9346) 약관 동의 한 줄. [bold]는 "전체 동의"(16 SemiBold)용,
/// [onView]가 있으면 오른쪽에 "보기"가 붙는다.
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
                          ? const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              letterSpacing: -0.32,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray07,
                            )
                          : const TextStyle(fontSize: 14, height: 1.4, color: AppColors.body),
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
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(10, 4, 0, 4),
              child: Text(
                '보기',
                style: TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.caption),
              ),
            ),
          ),
      ],
    );
  }
}

/// 시트 안의 사각 선택 상자(Chip, MBTI Option). 최소 높이 44·굴곡 8.
/// 선택되면 [selectedColor] 배경 + 파란 테두리.
class OptionBox extends StatelessWidget {
  const OptionBox({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.label,
    this.selectedColor = AppColors.blue01,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String? label;

  /// 선택된 바탕색. 준비시간 칩은 brandSoft, MBTI 옵션은 blue01.
  final Color selectedColor;

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
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.brand : AppColors.chipBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
