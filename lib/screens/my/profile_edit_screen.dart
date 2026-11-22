import 'package:flutter/material.dart';

import '../../widgets/character_picker.dart';
import '../../widgets/kit/kit.dart';
import 'my_data.dart';
import 'my_widgets.dart';

/// 12-1 프로필 편집(130:13023): 캐릭터(사진 변경) + 닉네임·한 줄 소개 입력 + 계정 정보 + 저장하기.
/// 저장하면 "프로필을 저장했어요" 토스트(130:15401)가 버튼 위에 뜬다.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final _nickname = TextEditingController(text: myProfile.value.nickname)..addListener(_refresh);
  late final _intro = TextEditingController(text: myProfile.value.intro);
  late int _character = myProfile.value.character;
  late int? _background = myProfile.value.background;

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _nickname.dispose();
    _intro.dispose();
    super.dispose();
  }

  /// 06_온보딩 완료(프로필 캐릭터)와 같은 고르기: 배경색 알약 + 미리보기 + Avatar/Character 가로 스와이프.
  Future<void> _pickCharacter() async {
    var character = _character;
    var color = _background ?? 1;
    final picked = await showAxisSheet<(int, int)>(
      context,
      title: '캐릭터 선택',
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // 시트 안쪽이 이미 좌우 20(가로 350)이라 알약·미리보기·스와이프 줄 모두 그 폭에 맞춘다.
            CharacterColorPicker(
              selected: color,
              fill: AppColors.searchBg,
              onChanged: (i) => setSheet(() => color = i),
            ),
            const SizedBox(height: 24),
            CharacterPreview(color: characterBackgrounds[color], character: character, size: 160),
            const SizedBox(height: 24),
            CharacterStrip(
              selected: character,
              padding: EdgeInsets.zero,
              onChanged: (c) => setSheet(() => character = c),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      footer: (ctx) => AxisCtaButton(label: '선택하기', onPressed: () => Navigator.pop(ctx, (character, color))),
    );
    if (picked != null) {
      setState(() {
        _character = picked.$1;
        _background = picked.$2;
      });
    }
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final nick = _nickname.text.trim();
    final current = myProfile.value;
    myProfile.value = current.copyWith(
      nickname: nick,
      callName: nick == current.nickname ? current.callName : nick,
      intro: _intro.text.trim(),
      character: _character,
      background: _background,
    );
    showAxisToast(context, '프로필을 저장했어요', bottom: 100);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nickname.text.trim().isNotEmpty;
    return MySubScaffold(
      title: '내 정보 수정',
      bottom: AxisCtaButton(label: '저장하기', enabled: canSave, onPressed: _save),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Semantics(
              button: true,
              label: '사진 변경',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: _pickCharacter,
                child: Column(
                  children: [
                    MyProfileAvatar(
                      character: _character,
                      size: 96,
                      background: _background == null ? null : characterBackgrounds[_background!],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '사진 변경',
                      style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.brand),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Column(
              children: [
                MyUnderlineField(label: '닉네임', controller: _nickname, maxLength: 10),
                const SizedBox(height: 32),
                MyUnderlineField(label: '한 줄 소개', controller: _intro, maxLength: 40),
              ],
            ),
          ),
          const AxisSectionDivider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('계정 정보', style: AxisText.groupLabel),
                SizedBox(height: 12),
                _InfoRow(
                  label: '이메일',
                  value: Text(MyProfile.email, style: _valueStyle),
                ),
                AxisDivider(),
                _InfoRow(label: '로그인 방식', value: _LoginTag(MyProfile.loginMethod)),
                AxisDivider(),
                _InfoRow(
                  label: '가입일',
                  value: Text(MyProfile.joinedAt, style: _valueStyle),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

const _valueStyle = TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500, color: AppColors.text);

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AxisText.body.copyWith(color: AppColors.gray06)),
          ),
          value,
        ],
      ),
    );
  }
}

class _LoginTag extends StatelessWidget {
  const _LoginTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.gray03, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.gray07),
      ),
    );
  }
}
