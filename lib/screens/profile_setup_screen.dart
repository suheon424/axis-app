import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_page.dart';
import '../widgets/form_widgets.dart';
import 'address_search_screen.dart';
import 'character_screen.dart';
import 'selection_sheets.dart';

/// 05 · 온보딩 기본 정보(빈 값 · 입력 중).
/// 각 칸을 누르면 5-1(준비시간 시트), 5-3(주소 검색), 5-2(MBTI 시트)로 이어지고,
/// 세 칸을 모두 채우면 시작하기가 활성화된다. "나중에 입력할게요"로 건너뛸 수 있다.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.nickname});

  final String nickname;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int? _prepMinutes;
  String? _address;
  String? _mbti;

  bool get _complete => _prepMinutes != null && _address != null && _mbti != null;

  Future<void> _pickPrepTime() async {
    final picked = await showPrepTimeSheet(context, initial: _prepMinutes);
    if (picked != null) setState(() => _prepMinutes = picked);
  }

  Future<void> _pickAddress() async {
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AddressSearchScreen()),
    );
    if (picked != null && picked.isNotEmpty) setState(() => _address = picked);
  }

  Future<void> _pickMbti() async {
    final picked = await showMbtiSheet(context, initial: _mbti);
    if (picked != null) setState(() => _mbti = picked);
  }

  void _next() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CharacterScreen(nickname: widget.nickname)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: '기본 정보',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextLinkButton(label: '나중에 입력할게요', onPressed: _next),
          const SizedBox(height: 4),
          BrandButton(label: '시작하기', enabled: _complete, onPressed: _next),
        ],
      ),
      children: [
        PageHeading('반가워요 ${widget.nickname}님!'),
        const SizedBox(height: 4),
        const PageSubheading(
          '입력한 정보로 출발 시간과 일정을 맞춰 드려요.\n언제든 설정에서 바꿀 수 있어요.',
          color: AppColors.body,
        ),
        const SizedBox(height: 40),
        AxisSelectField(
          label: '평소 준비시간',
          value: _prepMinutes == null ? null : '$_prepMinutes분',
          onTap: _pickPrepTime,
        ),
        const SizedBox(height: 16),
        AxisSelectField(label: '집 주소', value: _address, onTap: _pickAddress),
        const SizedBox(height: 16),
        AxisSelectField(label: 'MBTI', value: _mbti, onTap: _pickMbti),
        const SizedBox(height: 10),
        const Text('집 주소는 이동 시간 계산에만 사용해요.', style: TextStyle(fontSize: 13, color: AppColors.gray06)),
      ],
    );
  }
}
