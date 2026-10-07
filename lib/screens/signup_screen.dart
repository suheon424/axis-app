import 'package:flutter/material.dart';

import '../widgets/buttons.dart';
import '../widgets/form_page.dart';
import '../widgets/form_widgets.dart';
import 'profile_setup_screen.dart';

/// 04 · 회원가입(기본 정보 입력).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nickname = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pwConfirm = TextEditingController();
  bool _termsAgreed = true;
  bool _marketingAgreed = false;

  @override
  void dispose() {
    for (final c in [_nickname, _email, _pw, _pwConfirm]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() {
    if (_nickname.text.trim().isEmpty) return '닉네임을 입력해 주세요.';
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return '이메일 형식을 확인해 주세요.';
    if (_pw.text.length < 6) return '비밀번호는 6자 이상으로 입력해 주세요.';
    if (_pw.text != _pwConfirm.text) return '비밀번호가 서로 달라요.';
    if (!_termsAgreed) return '서비스 이용약관에 동의해 주세요.';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileSetupScreen(nickname: _nickname.text.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: '회원가입',
      bottomGap: 33,
      bottom: BrandButton(label: '회원가입 하기', onPressed: _submit),
      children: [
        const PageHeading('만나서 반가워요 😊'),
        const SizedBox(height: 4),
        const PageSubheading('기본 정보를 입력해주세요'),
        const SizedBox(height: 70),
        LabeledUnderlineField(
          label: '닉네임',
          hint: '닉네임을 입력해 주세요.',
          controller: _nickname,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        LabeledUnderlineField(
          label: '이메일',
          hint: '이메일을 입력해 주세요.',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        LabeledUnderlineField(
          label: '비밀번호',
          hint: '비밀번호를 입력해 주세요.',
          controller: _pw,
          obscure: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        LabeledUnderlineField(
          label: '비밀번호 확인',
          hint: '비밀번호를 한번 더 입력해 주세요.',
          controller: _pwConfirm,
          obscure: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AgreementCheck(
                label: '[필수] 서비스 이용약관 동의',
                checked: _termsAgreed,
                onChanged: (v) => setState(() => _termsAgreed = v),
              ),
              const SizedBox(height: 15),
              AgreementCheck(
                label: '[선택] 마케팅 정보 수신 동의',
                checked: _marketingAgreed,
                onChanged: (v) => setState(() => _marketingAgreed = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
