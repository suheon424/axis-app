import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_page.dart';
import '../widgets/form_widgets.dart';
import 'address_search_screen.dart';
import 'home_screen.dart';
import 'selection_sheets.dart';

/// 05 · 추가 정보 입력(빈 상태) / 08 · 같은 화면.
/// 각 항목을 누르면 06(준비시간 시트), 07(주소 검색), 09(MBTI 시트)로 이어진다.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.nickname});

  final String nickname;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String? _prepTime;
  String? _address;
  String? _mbti;

  static const _labelStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray07);

  Future<void> _pickPrepTime() async {
    final picked = await showPrepTimeSheet(context, initial: _prepTime);
    if (picked != null) setState(() => _prepTime = picked);
  }

  Future<void> _pickAddress() async {
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => AddressSearchScreen(initial: _address)),
    );
    if (picked != null && picked.isNotEmpty) setState(() => _address = picked);
  }

  Future<void> _pickMbti() async {
    final picked = await showMbtiSheet(context, initial: _mbti);
    if (picked != null) setState(() => _mbti = picked);
  }

  void _finish() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(nickname: widget.nickname)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: '회원가입',
      bottomGap: 26,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SecondaryButton(label: '건너뛰기', onPressed: _finish),
          const SizedBox(height: 10),
          BrandButton(label: '시작하기', onPressed: _finish),
        ],
      ),
      children: [
        PageHeading('반가워요 ${widget.nickname}님!', weight: FontWeight.w800),
        const SizedBox(height: 8),
        const PageSubheading('간단한 정보 입력하시면\n프로J만의 특별한 서비스를 경험할 수 있어요!'),
        const SizedBox(height: 49),
        LabeledUnderlineField(
          label: '평소 준비시간이 얼마나 걸리시나요?',
          hint: '몇 분인지 입력해 주세요',
          labelStyle: _labelStyle,
          hintColor: AppColors.hint,
          readOnly: true,
          value: _prepTime,
          onTap: _pickPrepTime,
        ),
        const SizedBox(height: 20),
        LabeledUnderlineField(
          label: '동선 관리를 위해 집 주소를 등록해주세요.',
          hint: '주소 입력하기',
          labelStyle: _labelStyle,
          hintColor: AppColors.hint,
          readOnly: true,
          value: _address,
          onTap: _pickAddress,
        ),
        const SizedBox(height: 20),
        LabeledUnderlineField(
          label: 'mbti 성향을 입력해주세요.',
          hint: 'mbti 성향을 입력해주세요.',
          labelStyle: _labelStyle,
          hintColor: AppColors.hint,
          readOnly: true,
          value: _mbti,
          onTap: _pickMbti,
        ),
      ],
    );
  }
}
