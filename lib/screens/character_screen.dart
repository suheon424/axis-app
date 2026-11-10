import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/form_widgets.dart';
import '../widgets/kit/kit_buttons.dart';
import '../widgets/character_picker.dart';
import 'home_screen.dart';
import 'my/my_data.dart';

/// 06_온보딩 완료(프로필 캐릭터). 배경색 8가지와 캐릭터 12종 중에서 고르면 가운데 미리보기가 바뀐다.
/// 시작하기·다음에 설정하기 → 07_01 홈.
class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key, required this.nickname});

  final String nickname;

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  int _color = 6;
  int _character = 4;

  void _finish({bool save = false}) {
    if (save) myProfile.value = myProfile.value.copyWith(character: _character + 1, background: _color);
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => HomeScreen(nickname: widget.nickname)), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
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
                            CharacterColorPicker(selected: _color, onChanged: (i) => setState(() => _color = i)),
                            const SizedBox(height: 26),
                            CharacterPreview(color: characterBackgrounds[_color], character: _character + 1),
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
              padding: const EdgeInsets.only(top: 21, bottom: AppSizes.ctaBottom),
              child: Column(
                children: [
                  CharacterStrip(selected: _character + 1, onChanged: (c) => setState(() => _character = c - 1)),
                  const SizedBox(height: 97),
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
            ),
          ],
        ),
      ),
    );
  }
}
