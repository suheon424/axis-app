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
  bool _submitting = false;

  /// 테스트용 기본값. 빈 칸으로 회원가입 하기를 누르면 이 값이 채워진다.
  static const _testDefaults = (
    nickname: '수현',
    email: 'h4s2h4@hansung.ac.kr',
    password: '0000',
  );

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
    if (_pw.text.length < 4) return '비밀번호는 4자 이상으로 입력해 주세요.';
    if (_pw.text != _pwConfirm.text) return '비밀번호가 서로 달라요.';
    if (!_termsAgreed) return '서비스 이용약관에 동의해 주세요.';
    return null;
  }

  /// 비어 있는 칸만 테스트용 기본값으로 채운다. 하나라도 채웠으면 true.
  bool _fillEmptyWithTestDefaults() {
    var filled = false;
    void fill(TextEditingController c, String value) {
      if (c.text.trim().isEmpty) {
        c.text = value;
        filled = true;
      }
    }

    fill(_nickname, _testDefaults.nickname);
    fill(_email, _testDefaults.email);
    fill(_pw, _testDefaults.password);
    fill(_pwConfirm, _testDefaults.password);
    return filled;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    if (_fillEmptyWithTestDefaults()) {
      // 채워진 값이 눈에 보이도록 잠깐 보여준 뒤 넘어간다.
      _submitting = true;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      _submitting = false;
      if (!mounted) return;
    }
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
