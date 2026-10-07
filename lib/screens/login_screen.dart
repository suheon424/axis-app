import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_page.dart';
import '../widgets/form_widgets.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

/// 02 · 로그인(빈 상태) / 03 · 로그인(입력 완료 상태).
/// 두 프레임은 같은 화면의 상태 차이라서 하나로 구현하고, 입력에 따라 02 → 03으로 애니메이션된다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController();
  final _pw = TextEditingController();

  @override
  void initState() {
    super.initState();
    _id.addListener(_refresh);
    _pw.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  bool get _canSubmit => _id.text.trim().isNotEmpty && _pw.text.isNotEmpty;

  void _submit() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(nickname: _id.text.trim())),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: '로그인',
      bottom: BrandButton(label: '로그인 하기', enabled: _canSubmit, onPressed: _submit),
      children: [
        const PageHeading('axis 플래너와 함께\n계획을 완성 할 준비 되셨나요?'),
        const SizedBox(height: 60),
        LabeledUnderlineField(
          label: '아이디',
          hint: '이메일 아이디를 입력해 주세요.',
          controller: _id,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        LabeledUnderlineField(
          label: '비밀번호',
          hint: '비밀번호를 입력해 주세요.',
          controller: _pw,
          obscure: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 30),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LinkText('비밀번호 찾기', onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('비밀번호 찾기는 준비 중이에요.')));
              }),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('|', style: TextStyle(fontSize: 14.37, color: AppColors.muted)),
              ),
              _LinkText('회원가입', onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignupScreen()));
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.text, {required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text, style: const TextStyle(fontSize: 14.37, color: AppColors.muted)),
    );
  }
}
