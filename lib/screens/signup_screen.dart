import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_page.dart';
import '../widgets/form_widgets.dart';
import 'profile_setup_screen.dart';

/// 04 · 회원가입(빈 값 · 입력 중 · 오류).
/// 네 칸을 모두 채우고 필수 약관에 동의해야 가입하기 버튼이 활성화된다.
/// 이메일 형식과 비밀번호 확인은 칸을 벗어날 때(또는 가입하기를 누를 때) 검사해 칸 아래에 알려 준다.
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
  final _emailFocus = FocusNode();
  final _pwFocus = FocusNode();
  final _pwConfirmFocus = FocusNode();
  bool _termsAgreed = false;
  bool _marketingAgreed = false;
  bool _submitting = false;

  /// 한 번이라도 벗어난 칸. 오류는 이 칸들에만 보여 준다.
  final _touched = <FocusNode>{};

  /// 테스트용 기본값. 빈 칸으로 가입하기를 누르면 이 값이 채워진다.
  static const _testDefaults = (
    nickname: '수현',
    email: 'h4s2h4@hansung.ac.kr',
    password: '0000',
  );

  @override
  void initState() {
    super.initState();
    for (final c in [_nickname, _email, _pw, _pwConfirm]) {
      c.addListener(_refresh);
    }
    for (final f in [_emailFocus, _pwFocus, _pwConfirmFocus]) {
      f.addListener(() {
        if (!f.hasFocus) _touched.add(f);
        _refresh();
      });
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_nickname, _email, _pw, _pwConfirm]) {
      c.dispose();
    }
    for (final f in [_emailFocus, _pwFocus, _pwConfirmFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _allFilled => [_nickname, _email, _pw, _pwConfirm].every((c) => c.text.trim().isNotEmpty);
  bool get _canSubmit => _allFilled && _termsAgreed;

  String? get _emailError {
    final email = _email.text.trim();
    if (email.isEmpty || !_touched.contains(_emailFocus)) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ? null : '이메일 형식을 확인해 주세요.';
  }

  String? get _pwError {
    if (_pw.text.isEmpty || !_touched.contains(_pwFocus)) return null;
    return _pw.text.length < 4 ? '비밀번호는 4자 이상으로 입력해 주세요.' : null;
  }

  String? get _pwConfirmError {
    if (_pwConfirm.text.isEmpty || !_touched.contains(_pwConfirmFocus)) return null;
    return _pw.text == _pwConfirm.text ? null : '비밀번호가 서로 달라요.';
  }

  bool get _allConsented => _termsAgreed && _marketingAgreed;

  void _setAll(bool v) => setState(() => _termsAgreed = _marketingAgreed = v);

  void _showViewNotice() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('약관 전문은 준비 중이에요.')));
  }

  /// 비어 있는 칸만 테스트용 기본값으로 채우고 약관에도 동의한다.
  Future<void> _fillTestDefaultsAndSubmit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    void fill(TextEditingController c, String value) {
      if (c.text.trim().isEmpty) c.text = value;
    }

    fill(_nickname, _testDefaults.nickname);
    fill(_email, _testDefaults.email);
    fill(_pw, _testDefaults.password);
    fill(_pwConfirm, _testDefaults.password);
    setState(() => _termsAgreed = true);
    // 채워진 값이 눈에 보이도록 잠깐 보여준 뒤 넘어간다.
    _submitting = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _submitting = false;
    if (mounted) _submit();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _touched.addAll([_emailFocus, _pwFocus, _pwConfirmFocus]));
    if (_emailError != null || _pwError != null || _pwConfirmError != null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileSetupScreen(nickname: _nickname.text.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: '회원가입',
      bottom: BrandButton(
        label: '가입하기',
        enabled: _canSubmit,
        onPressed: _submit,
        onDisabledPressed: _allFilled ? null : _fillTestDefaultsAndSubmit,
      ),
      children: [
        const PageHeading('만나서 반가워요 😊'),
        const SizedBox(height: 4),
        const PageSubheading('기본 정보를 입력해주세요'),
        const SizedBox(height: 40),
        AxisTextField(label: '닉네임', controller: _nickname, textInputAction: TextInputAction.next),
        const SizedBox(height: 16),
        AxisTextField(
          label: '이메일',
          controller: _email,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          error: _emailError,
        ),
        const SizedBox(height: 16),
        AxisTextField(
          label: '비밀번호',
          controller: _pw,
          focusNode: _pwFocus,
          obscure: true,
          textInputAction: TextInputAction.next,
          error: _pwError,
        ),
        const SizedBox(height: 16),
        AxisTextField(
          label: '비밀번호 확인',
          controller: _pwConfirm,
          focusNode: _pwConfirmFocus,
          obscure: true,
          textInputAction: TextInputAction.done,
          error: _pwConfirmError,
        ),
        const SizedBox(height: 32),
        ConsentRow(label: '전체 동의', bold: true, checked: _allConsented, onChanged: _setAll),
        const SizedBox(height: 14),
        const Divider(height: 1, thickness: 1, color: AppColors.divider),
        const SizedBox(height: 14),
        ConsentRow(
          label: '[필수] 서비스 이용약관 동의',
          checked: _termsAgreed,
          onChanged: (v) => setState(() => _termsAgreed = v),
          onView: _showViewNotice,
        ),
        const SizedBox(height: 14),
        ConsentRow(
          label: '[선택] 마케팅 정보 수신 동의',
          checked: _marketingAgreed,
          onChanged: (v) => setState(() => _marketingAgreed = v),
          onView: _showViewNotice,
        ),
      ],
    );
  }
}
