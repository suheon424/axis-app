import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../widgets/character_picker.dart' show characterBackgrounds, characterBackgroundNames;
import '../widgets/form_widgets.dart';
import '../widgets/kit/kit_buttons.dart';
import '../widgets/kit/media.dart';
import 'home_screen.dart';
import 'my/my_data.dart';

/// 06_온보딩 완료 (프로필 캐릭터)수정(281:11081).
///
/// 위(#F4F5FA): 프로필 설정 내비 · 제목 22 Bold("수현님,\n함께할 액시스 친구들을 골라봐요!") · 설명 14 ·
/// Avatar/Profile 140 원(고른 배경색 + 캐릭터, 제목 아래와 시트 위 사이 가운데).
/// 아래 흰 시트(위 굴곡 16, 그림자 0 -4 24 12%): 캐릭터(Avatar/Character 57, 간격 14, 옆으로 넘김) ·
/// 배경색(ColorSwatch 23.4 × 8) · 한줄 소개(40자, 지우기 아이콘, 밑줄) · 다음에 설정하기 / 시작하기.
/// 시작하기·다음에 설정하기 → 07_01 홈.
class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key, required this.nickname});

  final String nickname;

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  int _color = 6;
  int _character = 5;
  final _intro = TextEditingController();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _finish({bool save = false}) {
    if (save) {
      final intro = _intro.text.trim();
      myProfile.value = myProfile.value.copyWith(
        character: _character,
        background: _color,
        intro: intro.isEmpty ? null : intro,
      );
    }
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => HomeScreen(nickname: widget.nickname)), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.nickname.isEmpty ? '액시스' : widget.nickname;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: AppColors.searchBg),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.searchBg,
          body: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: MediaQuery.paddingOf(context).top),
                      const AxisNavBar(title: '프로필 설정'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 30, AppSizes.sidePadding, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$name님,\n함께할 액시스 친구들을 골라봐요!',
                              style: const TextStyle(
                                fontSize: 22,
                                height: 1.3,
                                letterSpacing: -0.22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '프로필 이미지는 나중에 얼마든지 변경 가능해요.',
                              style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.subText),
                            ),
                          ],
                        ),
                      ),
                      // 설명 아래와 시트 위 사이 가운데(피그마: 34 / 36).
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: ProfileAvatar(color: characterBackgrounds[_color], character: _character),
                          ),
                        ),
                      ),
                      _sheet(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.only(top: 22, bottom: AppSizes.ctaBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetLabel('캐릭터'),
          const SizedBox(height: 8),
          CharacterRow(selected: _character, onChanged: (c) => setState(() => _character = c)),
          const SizedBox(height: 25),
          const _SheetLabel('배경색'),
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding + 4.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < characterBackgrounds.length; i++)
                  _Swatch(
                    color: characterBackgrounds[i],
                    label: '배경색 ${characterBackgroundNames[i]}',
                    selected: i == _color,
                    onTap: () => setState(() => _color = i),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
            child: _IntroField(controller: _intro),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
            child: AxisSplitButton(
              leftLabel: '다음에 설정하기',
              rightLabel: '시작하기',
              onLeft: _finish,
              onRight: () => _finish(save: true),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sheet/Header: 16 SemiBold #1F2027(줄 높이 130%, 자간 -1%).
class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text, {this.trailing});

  final String text;
  final Widget? trailing;

  static const style = TextStyle(
    fontSize: 16,
    height: 1.3,
    letterSpacing: -0.16,
    fontWeight: FontWeight.w600,
    color: AppColors.gray07,
  );

  @override
  Widget build(BuildContext context) {
    final label = Text(text, style: style);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: trailing == null ? AppSizes.sidePadding : 0),
      child: trailing == null
          ? label
          : Row(
              children: [
                Expanded(child: label),
                trailing!,
              ],
            ),
    );
  }
}

/// 선택 표시(피그마 Selected 프레임 흰 2 + 파랑 6, 모두 바깥쪽): 흰 2 고리 바깥에 파랑 4 고리.
const _selectedRing = [
  BoxShadow(color: AppColors.brand, spreadRadius: 6),
  BoxShadow(color: Colors.white, spreadRadius: 2),
];

/// Avatar/Profile(140 원): 고른 배경색 위에 Avatar/Character 컴포넌트 그림을 꽉 채운다.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.color, required this.character, this.size = 140});

  final Color color;
  final int character;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Image.asset(
          AxisAvatar.squareAsset(character),
          key: ValueKey(character),
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

/// Avatar/Character(130:9997) 12개를 옆으로 넘겨 고르는 줄. 칸 57(굴곡 4, #EDEEF6), 간격 14, 양끝 20.
/// [selected]는 1~12. 고른 칸이 첫 화면 밖이면 보이도록 넘겨 둔다.
class CharacterRow extends StatefulWidget {
  const CharacterRow({super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  static const item = 57.0;
  static const gap = 14.0;

  /// 선택 고리(6)가 잘리지 않게 위아래로 두는 여백.
  static const ringRoom = 8.0;

  @override
  State<CharacterRow> createState() => _CharacterRowState();
}

class _CharacterRowState extends State<CharacterRow> {
  late final _scroll = ScrollController(
    initialScrollOffset: ((widget.selected - 5) * (CharacterRow.item + CharacterRow.gap)).clamp(0, double.infinity),
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CharacterRow.item + CharacterRow.ringRoom * 2,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding, vertical: CharacterRow.ringRoom),
        itemCount: 12,
        separatorBuilder: (_, _) => const SizedBox(width: CharacterRow.gap),
        itemBuilder: (context, i) {
          final c = i + 1;
          final selected = c == widget.selected;
          return Semantics(
            button: true,
            selected: selected,
            label: '캐릭터 $c',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => widget.onChanged(c),
              child: SizedBox(
                width: CharacterRow.item,
                height: CharacterRow.item,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 피그마 Selected: 파랑 6 · 흰 2 모두 바깥쪽 테두리라 바깥 굴곡이 4+6, 4+2로 커진다.
                    if (selected) ...const [
                      Positioned.fill(
                        left: -6,
                        top: -6,
                        right: -6,
                        bottom: -6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.brand,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        left: -2,
                        top: -2,
                        right: -2,
                        bottom: -2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                      ),
                    ],
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ColoredBox(
                          color: AppColors.gray02,
                          child: Image.asset(
                            AxisAvatar.squareAsset(c),
                            fit: BoxFit.cover,
                            cacheWidth: 180,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ColorSwatch(23.4 원). 고르면 흰 2 + 파랑 고리. 누르는 영역은 둘레로 넓힌다.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label, required this.selected, required this.onTap});

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const size = 23.4;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: selected ? _selectedRing : null),
        ),
      ),
    );
  }
}

/// 한줄 소개: 라벨(16 SemiBold) + 오른쪽 글자 수(12 #636C78) / 입력(16 Medium #191F28) + 지우기 / 밑줄 #E5E8EB.
class _IntroField extends StatefulWidget {
  const _IntroField({required this.controller});

  final TextEditingController controller;

  static const maxLength = 40;

  @override
  State<_IntroField> createState() => _IntroFieldState();
}

class _IntroFieldState extends State<_IntroField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetLabel(
          '한줄 소개',
          trailing: Text(
            '${text.characters.length}/${_IntroField.maxLength}',
            style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray06),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E8EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  maxLength: _IntroField.maxLength,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    letterSpacing: -0.32,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF191F28),
                  ),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    border: InputBorder.none,
                    counterText: '',
                    hintText: '계획은 작게, 실행은 꾸준히',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      letterSpacing: -0.32,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB0B8C1),
                    ),
                  ),
                ),
              ),
              if (text.isNotEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.controller.clear,
                  child: Semantics(
                    button: true,
                    label: '지우기',
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SvgPicture.asset('assets/icons/ic_clear.svg', width: 18, height: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
