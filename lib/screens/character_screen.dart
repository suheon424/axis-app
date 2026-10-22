import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_widgets.dart';
import 'home_screen.dart';

/// 06 · 프로필 캐릭터 고르기. 배경색 8가지와 캐릭터 12종 중에서 고르면 위 미리보기가 바뀐다.
class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key, required this.nickname});

  final String nickname;

  static const backgrounds = [
    Color(0xFFEDAA00),
    Color(0xFF0057ED),
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(nickname: widget.nickname)),
      (_) => false,
    );
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
                    const SizedBox(height: 4),
                    const AxisNavBar(title: '프로필 설정'),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 28, AppSizes.sidePadding, 24),
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
                                  height: 1.32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _ColorPicker(selected: _color, onChanged: (i) => setState(() => _color = i)),
                            const SizedBox(height: 30),
                            _Preview(
                              color: CharacterScreen.backgrounds[_color],
                              image: CharacterScreen.characters[_character],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$name 님',
                              style: const TextStyle(
                                fontSize: 20,
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
              padding: EdgeInsets.only(top: 21, bottom: safeBottom > 24 ? safeBottom : 24),
              child: Column(
                children: [
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding, vertical: 2),
                      itemCount: CharacterScreen.characters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 7),
                      itemBuilder: (context, i) => _CharacterTile(
                        image: CharacterScreen.characters[i],
                        index: i,
                        selected: i == _character,
                        onTap: () => setState(() => _character = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 27),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
                    child: Column(
                      children: [
                        SecondaryButton(label: '다음에 설정하기', onPressed: _finish),
                        const SizedBox(height: 10),
                        BrandButton(label: '시작하기', onPressed: _finish),
                      ],
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

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          const Text(
            '배경색',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray06),
          ),
          const SizedBox(width: 8),
          for (var i = 0; i < CharacterScreen.backgrounds.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                label: '배경색 ${CharacterScreen.backgroundNames[i]}',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: SizedBox(
                    height: 32,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: i == selected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: CharacterScreen.backgrounds[i]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.color, required this.image});

  final Color color;
  final String image;

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
        child: Align(
          key: ValueKey(image),
          alignment: Alignment.bottomCenter,
          child: Image.asset(image, width: 137, fit: BoxFit.fitWidth),
        ),
      ),
    );
  }
}

class _CharacterTile extends StatelessWidget {
  const _CharacterTile({required this.image, required this.index, required this.selected, required this.onTap});

  final String image;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '캐릭터 ${index + 1}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.gray02,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2.12),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.bottomCenter,
          child: Image.asset(image, width: 46, fit: BoxFit.fitWidth, excludeFromSemantics: true),
        ),
      ),
    );
  }
}
