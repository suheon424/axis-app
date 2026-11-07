import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';

/// Avatar/Character(130:9997): 캐릭터 01~12(assets/images/characters/char_XX.png)를
/// 회색(#EDEEF6) 굴곡 8 상자에 담는다. [selected]면 파란 2px 테두리.
class AxisAvatar extends StatelessWidget {
  const AxisAvatar({
    super.key,
    required this.character,
    this.size = 60,
    this.selected = false,
    this.onTap,
    this.square = false,
  });

  /// 1~12
  final int character;
  final double size;
  final bool selected;
  final VoidCallback? onTap;

  /// true면 피그마 원본 비율(정사각형, 캐릭터 둘레 여백 포함) 이미지를 쓴다(06 캐릭터 고르기 화면).
  final bool square;

  static String asset(int character) => 'assets/images/characters/char_${character.toString().padLeft(2, '0')}.png';

  /// 피그마 Character 1~12(130:9999~) 원본 그대로의 정사각형 이미지.
  static String squareAsset(int character) =>
      'assets/images/characters/square/char_${character.toString().padLeft(2, '0')}.png';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: '캐릭터 $character',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.gray02,
            borderRadius: BorderRadius.circular(8 * size / 60),
            border: selected ? Border.all(color: AppColors.brand, width: 2) : null,
          ),
          child: Image.asset(square ? squareAsset(character) : asset(character), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// Icon/Event(130:10220)의 3D 메탈 이벤트 아이콘(assets/images/kit/event_*.png, 120px).
enum AxisEventIconType {
  attendance('출석', 'attendance'),
  planKing('계획왕', 'plan_king'),
  affirmation('확언', 'affirmation'),
  invite('친구 초대', 'invite'),
  badge('배지', 'badge');

  const AxisEventIconType(this.label, this.file);

  final String label;
  final String file;

  String get asset => 'assets/images/kit/event_$file.png';
}

/// Icon/Event(130:10220): 콘텐츠용 3D 메탈 아이콘(기본 40px).
class AxisEventIcon extends StatelessWidget {
  const AxisEventIcon(this.type, {super.key, this.size = 40});

  final AxisEventIconType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(type.asset, width: size, height: size, semanticLabel: type.label);
  }
}

/// AI/Orb(130:10215): 파란 빛이 번지는 AI 구슬. [size]는 가운데 구슬 지름(기본 80);
/// 빛까지 포함한 그림은 [size]×2.5 크기로 그려지며, 레이아웃은 [size]만 차지한다.
/// [pulse]면 숨 쉬듯 천천히 커졌다 작아진다.
class AxisAiOrb extends StatefulWidget {
  const AxisAiOrb({super.key, this.size = 80, this.pulse = false});

  final double size;
  final bool pulse;

  static const asset = 'assets/images/kit/ai_orb.png';

  @override
  State<AxisAiOrb> createState() => _AxisAiOrbState();
}

class _AxisAiOrbState extends State<AxisAiOrb> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AxisAiOrb old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.pulse && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: OverflowBox(
        maxWidth: s * 2.5,
        maxHeight: s * 2.5,
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
          child: Image.asset(AxisAiOrb.asset, width: s * 2.5, height: s * 2.5, semanticLabel: 'AI'),
        ),
      ),
    );
  }
}

/// Map/Pin(130:10194): 지도 위 24px 원형 핀. 번호 핀(기본 초록·흰 2px 테두리) 또는 [home] 핀(파랑 + 집 모양).
class AxisMapPin extends StatelessWidget {
  const AxisMapPin({super.key, this.number, this.color = CubeColors.green, this.home = false, this.size = 24});

  /// 번호 핀의 숫자. [home]이면 무시.
  final int? number;

  /// 번호 핀 색(일정 카테고리 색).
  final Color color;
  final bool home;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: home ? AppColors.brand : color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: home ? 1.5 : 2),
        boxShadow: const [BoxShadow(color: Color(0x2E000000), blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: home
          ? AxisIcon(KitIcon.homeGlyph, size: size * 9 / 24, color: Colors.white)
          : Text(
              '${number ?? ''}',
              style: const TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w600, color: Colors.white),
            ),
    );
  }
}
