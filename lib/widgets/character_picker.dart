import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'kit/media.dart';
import 'kit/selection.dart';

/// 06_온보딩 완료(프로필 캐릭터)와 내 정보 수정의 캐릭터 고르기가 함께 쓰는 조각:
/// 배경색 알약, Avatar/Profile 미리보기, Avatar/Character 가로 스와이프 줄.

/// 배경색 8가지(ColorSwatch).
const characterBackgrounds = [
  Color(0xFFEDAA00),
  AppColors.brand,
  Color(0xFF009156),
  Color(0xFFFF6002),
  Color(0xFFE00000),
  Color(0xFFAFAFAF),
  Color(0xFFCCD1DD),
  Color(0xFF1F2027),
];

const characterBackgroundNames = ['노랑', '파랑', '초록', '주황', '빨강', '회색', '연회색', '검정'];

/// Avatar/Character(130:9997) 12종을 가로로 넘겨 고르는 줄(60 정사각, 간격 8). [selected]는 1~12.
class CharacterStrip extends StatefulWidget {
  const CharacterStrip({super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  State<CharacterStrip> createState() => _CharacterStripState();
}

class _CharacterStripState extends State<CharacterStrip> {
  static const _item = 60.0;
  static const _gap = 8.0;

  // 고른 캐릭터가 첫 화면(5개) 밖이면 보이도록 그만큼만 넘겨 둔다.
  late final _scroll = ScrollController(initialScrollOffset: math.max(0, (widget.selected - 5) * (_item + _gap)));

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _item,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
        itemCount: 12,
        separatorBuilder: (_, _) => const SizedBox(width: _gap),
        itemBuilder: (context, i) => AxisAvatar(
          character: i + 1,
          square: true,
          selected: i + 1 == widget.selected,
          onTap: () => widget.onChanged(i + 1),
        ),
      ),
    );
  }
}

/// 흰 알약 안의 "배경색" + ColorSwatch 8개(간격 16).
class CharacterColorPicker extends StatelessWidget {
  const CharacterColorPicker({super.key, required this.selected, required this.onChanged, this.fill = Colors.white});

  final int selected;

  /// 알약 바탕. 흰 시트 위에서는 회색으로 둔다.
  final Color fill;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // 스와치마다 탭 여유 6이 붙어 있어 피그마 간격(16)에서 그만큼 뺀다.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 8.5, 18, 8.5),
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          const Text(
            '배경색',
            style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.gray06),
          ),
          const SizedBox(width: 10),
          for (var i = 0; i < characterBackgrounds.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Semantics(
              label: '배경색 ${characterBackgroundNames[i]}',
              child: AxisColorSwatch(
                color: characterBackgrounds[i],
                selected: i == selected,
                onTap: () => onChanged(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar/Profile: 180 상자(굴곡 18)에 고른 배경색 + 캐릭터.
class CharacterPreview extends StatelessWidget {
  const CharacterPreview({super.key, required this.color, required this.character, this.size = 180});

  final double size;

  final Color color;
  final int character;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18 * size / 180)),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: Image.asset(
          AxisAvatar.squareAsset(character),
          key: ValueKey(character),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
