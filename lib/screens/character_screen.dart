import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/form_widgets.dart';
import '../widgets/kit/kit_buttons.dart';
import '../widgets/kit/media.dart';
import '../widgets/kit/selection.dart';
import 'home_screen.dart';

/// 06_온보딩 완료(프로필 캐릭터). 배경색 8가지와 캐릭터 12종 중에서 고르면 가운데 미리보기가 바뀐다.
/// 시작하기·다음에 설정하기 → 07_01 홈.
class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key, required this.nickname});

  final String nickname;

  static const backgrounds = [
    Color(0xFFEDAA00),
    AppColors.brand,
    Color(0xFF009156),
    Color(0xFFFF6002),
    Color(0xFFE00000),
    Color(0xFFAFAFAF),
    Color(0xFFCCD1DD),
    Color(0xFF1F2027),
  ];

  static const backgroundNames = ['노랑', '파랑', '초록', '주황', '빨강', '회색', '연회색', '검정'];

  static final characters = [
    for (var i = 1; i <= 12; i++) 'assets/images/characters/char_${i.toString().padLeft(2, '0')}.png',
  ];

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  int _color = 6;
  int _character = 4;

  void _finish() {
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => HomeScreen(nickname: widget.nickname)), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final name = widget.nickname.isEmpty ? '액시스' : widget.nickname;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: AppColors.searchBg),
      child: Scaffold(
        backgroundColor: AppColors.searchBg,
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const AxisNavBar(title: '프로필 설정'),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 30, AppSizes.sidePadding, 24),
                        child: Column(
                          children: [
                            const SizedBox(
                              width: double.infinity,
                              child: Text(
                                '모든 준비가 완료되었어요!',
                                style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.subText),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const SizedBox(
                              width: double.infinity,
                              child: Text(
                                '액시스와 함께할\n프로필 캐릭터를 골라봐요!',
                                style: TextStyle(
                                  fontSize: 22,
                                  height: 1.3,
                                  letterSpacing: -0.22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            _ColorPicker(selected: _color, onChanged: (i) => setState(() => _color = i)),
                            const SizedBox(height: 26),
                            _Preview(color: CharacterScreen.backgrounds[_color], character: _character + 1),
                            const SizedBox(height: 10),
                            Text(
                              '$name 님',
                              style: const TextStyle(
                                fontSize: 20,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gray07,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 21, bottom: safeBottom > 22 ? safeBottom : 22),
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
                      itemCount: CharacterScreen.characters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => AxisAvatar(
                        character: i + 1,
                        selected: i == _character,
                        onTap: () => setState(() => _character = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 97),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
                    child: AxisSplitButton(
                      leftLabel: '다음에 설정하기',
                      rightLabel: '시작하기',
                      onLeft: _finish,
                      onRight: _finish,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 흰 알약 안의 "배경색" + ColorSwatch 8개(간격 16).
class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // 스와치마다 탭 여유 6이 붙어 있어 피그마 간격(16)에서 그만큼 뺀다.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 8.5, 18, 8.5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          const Text(
            '배경색',
            style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.gray06),
          ),
          const SizedBox(width: 10),
          for (var i = 0; i < CharacterScreen.backgrounds.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Semantics(
              label: '배경색 ${CharacterScreen.backgroundNames[i]}',
              child: AxisColorSwatch(
                color: CharacterScreen.backgrounds[i],
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
class _Preview extends StatelessWidget {
  const _Preview({required this.color, required this.character});

  final Color color;
  final int character;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 180,
      height: 180,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
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
          AxisAvatar.asset(character),
          key: ValueKey(character),
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
