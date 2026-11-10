import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/form_page.dart';
import '../widgets/form_widgets.dart';
import '../widgets/kit/dialogs.dart';
import '../widgets/kit/kit_buttons.dart';

/// 03-1 비밀번호 찾기 · 입력: 가입한 이메일을 넣으면 재설정 링크 받기가 켜지고, 누르면 03-2로 간다.
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  late final _email = TextEditingController(text: widget.initialEmail)..addListener(() => setState(() {}));

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool get _ready => _email.text.trim().contains('@');

  void _send() {
    FocusScope.of(context).unfocus();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => PasswordResetSentScreen(email: _email.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: '비밀번호 찾기',
      bottom: AxisCtaButton(label: '재설정 링크 받기', enabled: _ready, onPressed: _send),
      children: [
        const PageHeading('가입한 이메일을\n알려 주세요'),
        const SizedBox(height: 8),
        const PageSubheading('비밀번호를 다시 설정할 수 있는 링크를 보내드려요.', color: AppColors.gray06),
        const SizedBox(height: 24),
        AxisTextField(
          label: '이메일',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          placeholderColor: AppColors.gray04,
          onSubmitted: (_) {
            if (_ready) _send();
          },
        ),
      ],
    );
  }
}

/// 03-2 비밀번호 찾기 · 메일 발송 완료: 보낸 주소를 보여 주고, 다시 보내거나 로그인으로 돌아간다.
class PasswordResetSentScreen extends StatelessWidget {
  const PasswordResetSentScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: '비밀번호 찾기',
      bottom: AxisCtaButton(label: '로그인으로 돌아가기', onPressed: () => Navigator.of(context).pop()),
      children: [
        const PageHeading('메일을 보냈어요'),
        const SizedBox(height: 8),
        const Text(
          '받은 메일의 링크를 눌러 새 비밀번호를 설정해 주세요.\n메일이 없다면 스팸함도 확인해 주세요.',
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.gray06),
        ),
        const SizedBox(height: 31),
        // sent/email: gray03 바탕, 굴곡 6, 높이 44.
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.gray03, borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              const Text('받는 사람', style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showAxisToast(context, '메일을 다시 보냈어요'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('메일 다시 보내기', style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.muted)),
            ),
          ),
        ),
      ],
    );
  }
}
