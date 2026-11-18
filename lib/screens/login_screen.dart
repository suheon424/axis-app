import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/form_page.dart';
import '../widgets/form_widgets.dart';
import '../widgets/kit/kit_buttons.dart';
import 'password_reset_screen.dart';
import 'profile_setup_screen.dart';
import 'signup_screen.dart';

/// 로그인 실패 시 비밀번호 칸 아래에 보여 주는 문구(03 로그인 · 실패).
const loginFailedMessage = '이메일 또는 비밀번호가 일치하지 않아요.';

/// 02 로그인 · 빈값 / 03 로그인 · 입력중 · 입력완료 · 실패.
/// 네 프레임은 같은 화면의 상태 차이라서 하나로 구현했다. 두 칸을 채워야 로그인 버튼이 활성화되고,
/// 계정 확인에 실패하면 비밀번호 칸이 오류 상태가 된다(다시 입력하면 사라진다).
/// 성공하면 05 온보딩 · 빈값으로 이어진다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.verify = defaultVerify, this.prefill = false});

  /// true면 시연용 계정(demo@axis.app / 1234)이 미리 채워져 있어 바로 로그인을 누를 수 있다("이메일로 로그인하기").
  final bool prefill;

  static const demoEmail = 'demo@axis.app';
  static const demoPassword = '1234';

  /// 계정 확인. 서버가 없는 시연용이라 기본값은 두 칸에 아무 값이나 넣으면 통과한다.
  /// 03 로그인 · 실패 화면은 [verify]를 바꿔(테스트) 볼 수 있다.
  final bool Function(String email, String password) verify;

  static bool defaultVerify(String email, String password) => email.isNotEmpty && password.isNotEmpty;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _id = TextEditingController(text: widget.prefill ? LoginScreen.demoEmail : '');
  late final _pw = TextEditingController(text: widget.prefill ? LoginScreen.demoPassword : '');
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _id.addListener(_onEdit);
    _pw.addListener(_onEdit);
  }

  String _lastId = '';
  String _lastPw = '';

  void _onEdit() {
    final changed = _id.text != _lastId || _pw.text != _lastPw;
    _lastId = _id.text;
    _lastPw = _pw.text;
    setState(() {
      if (changed) _failed = false;
    });
  }

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  bool get _canSubmit => _id.text.trim().isNotEmpty && _pw.text.isNotEmpty;

  void _submit() {
    FocusScope.of(context).unfocus();
    final email = _id.text.trim();
    if (!widget.verify(email, _pw.text)) {
      setState(() => _failed = true);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileSetupScreen(nickname: email.split('@').first)));
  }

  /// 03-1 비밀번호 찾기(로그인 칸에 적은 이메일을 이어서 채운다).
  void _findPassword() =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => PasswordResetScreen(initialEmail: _id.text.trim())));

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: '로그인',
      bottom: AxisCtaButton(label: '로그인', enabled: _canSubmit, onPressed: _submit),
      children: [
        const PageHeading('axis 플래너와 함께\n계획을 완성할 준비 되셨나요?'),
        const SizedBox(height: 53),
        AxisTextField(
          label: '이메일',
          controller: _id,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          placeholderColor: AppColors.gray04,
        ),
        const SizedBox(height: 24),
        AxisTextField(
          label: '비밀번호',
          controller: _pw,
          obscure: true,
          textInputAction: TextInputAction.done,
          placeholderColor: AppColors.gray04,
          error: _failed ? loginFailedMessage : null,
          onSubmitted: (_) {
            if (_canSubmit) _submit();
          },
        ),
        const SizedBox(height: 26),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LinkText('비밀번호 찾기', onTap: _findPassword),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('|', style: _linkStyle),
              ),
              _LinkText(
                '회원가입',
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignupScreen()));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const _linkStyle = TextStyle(fontSize: 14, height: 1.4, color: AppColors.muted);

class _LinkText extends StatelessWidget {
  const _LinkText(this.text, {required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text, style: _linkStyle),
      ),
    );
  }
}
