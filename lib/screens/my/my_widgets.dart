import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';

/// 마이 탭 하위 화면 공통 틀: 흰 바탕 + 상단 표시줄 여백 10 + Nav/Back Title + 내용 + (아래 고정 버튼).
class MySubScaffold extends StatelessWidget {
  const MySubScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.onTitleLongPress,
    this.resizeToAvoidBottomInset = true,
  });

  final String title;
  final Widget body;

  /// 아래에 붙는 버튼 영역(위 1px 선 + 여백 포함으로 감싸 준다).
  final Widget? bottom;

  /// 데모용: 제목을 길게 누르면 빈 상태 등 다른 상태로 바꾼다.
  final VoidCallback? onTitleLongPress;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onLongPress: onTitleLongPress,
                child: AxisBackTitleBar(title: title),
              ),
              Expanded(child: body),
            ],
          ),
        ),
        bottomNavigationBar: bottom == null ? null : MyBottomBar(child: bottom!),
      ),
    );
  }
}

/// 화면 아래 고정 버튼 영역: 위 1px #EDEEF6 선, 좌우 20, 위 10, 아래 홈 인디케이터 + 12.
class MyBottomBar extends StatelessWidget {
  const MyBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray02)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, inset + 12),
      // 버튼 안의 Alignment가 높이를 꽉 채우지 않도록 세로 제약을 풀어 준다.
      child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
    );
  }
}

/// 목록 위 "게시물 3" 머리줄(14 SemiBold, 개수는 파랑) + 아래 1px gray04 선. [trailing]은 오른쪽(필터 등).
class MyCountHeader extends StatelessWidget {
  const MyCountHeader({super.key, required this.label, required this.count, this.trailing, this.onLongPress});

  final String label;
  final int count;
  final Widget? trailing;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray04)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '$label '),
                    TextSpan(
                      text: '$count',
                      style: TextStyle(color: count > 0 ? AppColors.brand : AppColors.text),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.text),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// 마이 탭 빈 상태: 56px 회색 원 아이콘 + 제목 + 설명 + 작은 버튼(파랑 채움 또는 흰 테두리).
class MyEmptyState extends StatelessWidget {
  const MyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.outline = false,
  });

  final String icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.gray01, shape: BoxShape.circle),
            child: AxisIcon(icon, color: AppColors.subIcon),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AxisText.rowTitle.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AxisText.body.copyWith(color: AppColors.gray06),
          ),
          const SizedBox(height: 16),
          AxisSmallButton(label: actionLabel, outline: outline, onPressed: onAction),
        ],
      ),
    );
  }
}

/// 위 라벨(12) + 입력값(16) + 오른쪽 글자 수 + 밑줄. 포커스되면 라벨·밑줄이 파랑 2px.
class MyUnderlineField extends StatefulWidget {
  const MyUnderlineField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLength,
    this.hint,
    this.maxLines = 1,
    this.clearable = false,
    this.counterBelow = false,
  });

  final String label;
  final TextEditingController controller;
  final int? maxLength;
  final String? hint;

  /// null이면 글자에 맞춰 여러 줄로 늘어난다.
  final int? maxLines;

  /// 값이 있을 때 오른쪽 지우기(ⓧ) 버튼.
  final bool clearable;

  /// 글자 수를 밑줄 아래 오른쪽에 둔다(긴 내용 입력용).
  final bool counterBelow;

  @override
  State<MyUnderlineField> createState() => _MyUnderlineFieldState();
}

class _MyUnderlineFieldState extends State<MyUnderlineField> {
  final _focus = FocusNode();

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
    widget.controller.removeListener(_refresh);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final text = widget.controller.text;
    final counter = widget.maxLength == null
        ? null
        : Text('${text.characters.length}/${widget.maxLength}', style: AxisText.caption);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 12, height: 1.4, color: focused ? AppColors.brand : AppColors.gray06),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _focus.requestFocus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            constraints: const BoxConstraints(minHeight: 40),
            padding: EdgeInsets.only(bottom: focused ? 7 : 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: focused ? AppColors.brand : AppColors.gray02, width: focused ? 2 : 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    maxLines: widget.maxLines,
                    minLines: 1,
                    inputFormatters: [if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength)],
                    style: const TextStyle(fontSize: 16, height: 1.5, letterSpacing: -0.32, color: AppColors.text),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.hint,
                      hintStyle: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.gray05),
                    ),
                  ),
                ),
                if (widget.clearable && text.isNotEmpty)
                  Semantics(
                    button: true,
                    label: '${widget.label} 지우기',
                    child: GestureDetector(
                      onTap: widget.controller.clear,
                      child: Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(left: 8, bottom: 3),
                        decoration: const BoxDecoration(color: AppColors.gray05, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
                      ),
                    ),
                  ),
                if (counter != null && !widget.counterBelow) ...[const SizedBox(width: 8), counter],
              ],
            ),
          ),
        ),
        if (counter != null && widget.counterBelow)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(alignment: Alignment.centerRight, child: counter),
          ),
      ],
    );
  }
}

/// 사선으로 나뉜 두 버튼: 왼쪽 회색 보조 + 오른쪽 빨간 채움(탈퇴 같은 위험한 메인). 오른쪽은 [rightEnabled] 전까지 회색.
class MyDangerSplitButton extends StatelessWidget {
  const MyDangerSplitButton({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeft,
    required this.onRight,
    required this.rightEnabled,
  });

  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final bool rightEnabled;

  @override
  Widget build(BuildContext context) {
    final style = AxisText.button.copyWith(fontFamily: 'Pretendard');
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PressBuilder(
              semanticLabel: leftLabel,
              onTap: onLeft,
              builder: (_, _) => CustomPaint(
                painter: PolygonPainter(fill: AppColors.gray02, build: (s) => _half(s, left: true)),
                child: _label(leftLabel, style.copyWith(color: AppColors.gray07)),
              ),
            ),
          ),
          Expanded(
            child: PressBuilder(
              semanticLabel: rightLabel,
              onTap: rightEnabled ? onRight : null,
              builder: (_, pressed) => CustomPaint(
                painter: PolygonPainter(
                  fill: !rightEnabled
                      ? AppColors.disabledFill
                      : pressed
                      ? const Color(0xFFB80000)
                      : AppColors.error,
                  build: (s) => _half(s, left: false),
                ),
                child: _label(rightLabel, style.copyWith(color: rightEnabled ? Colors.white : AppColors.gray06)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, TextStyle style) => Container(
    constraints: const BoxConstraints(minHeight: AppSizes.buttonHeight),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    child: Text(text, style: style, textAlign: TextAlign.center),
  );

  static Path _half(Size size, {required bool left}) {
    final w = size.width, h = size.height;
    final s = h * 0.6;
    const g = 3.0, r = 8.0;
    if (left) {
      return roundedPolygon(
        [const Offset(0, 0), Offset(w + s / 2 - g, 0), Offset(w - s / 2 - g, h), Offset(0, h)],
        [r, 0, 0, r],
      );
    }
    return roundedPolygon([Offset(s / 2 + g, 0), Offset(w, 0), Offset(w, h), Offset(-s / 2 + g, h)], [0, r, r, 0]);
  }
}

/// 원형 연파랑 바탕에 캐릭터(AxisAvatar 이미지)를 담은 프로필 사진.
class MyProfileAvatar extends StatelessWidget {
  const MyProfileAvatar({super.key, required this.character, this.size = 70, this.background});

  final int character;
  final double size;

  /// 고른 배경색. null이면 연파랑.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: background ?? AppColors.blue01, shape: BoxShape.circle),
      // 피그마(12 · 12-1)처럼 정사각형 캐릭터를 원의 90.6% 크기로, 위에서 7.3% 내려 가운데 둔다.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * 0.047,
            top: size * 0.073,
            width: size * 0.906,
            height: size * 0.906,
            child: Image.asset(AxisAvatar.squareAsset(character), fit: BoxFit.cover, semanticLabel: '프로필 캐릭터'),
          ),
        ],
      ),
    );
  }
}
