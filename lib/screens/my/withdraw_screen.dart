import 'package:flutter/material.dart';

import '../../widgets/form_widgets.dart';
import '../../widgets/kit/kit.dart';
import '../welcome_screen.dart';
import 'my_data.dart';
import 'my_widgets.dart';
import 'notification_settings_screen.dart';

/// 12-11 탈퇴하기(130:13372): 사라지는 내용 요약 + 떠나는 이유(라디오) + 확인 체크 + 더 써볼게요 / 탈퇴하기.
/// 이유를 고르고 확인에 체크해야 탈퇴하기가 빨갛게 켜진다. "알림이 너무 많아요"를 고르면 알림 설정 바로가기 안내가 열린다.
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  static const _reasons = ['사용 방법이 어려워요', '원하는 기능이 없어요', '알림이 너무 많아요', '다른 앱을 쓰게 됐어요', '기타'];
  static const _noisyAlarm = 2;

  int? _reason;
  bool _confirmed = false;

  void _withdraw() {
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = myProfile.value;
    return MySubScaffold(
      title: '탈퇴하기',
      bottom: MyDangerSplitButton(
        leftLabel: '더 써볼게요',
        rightLabel: '탈퇴하기',
        onLeft: () => Navigator.of(context).maybePop(),
        onRight: _withdraw,
        rightEnabled: _reason != null && _confirmed,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${profile.callName} 님, 정말 떠나시나요?',
                  style: AxisText.sectionTitle.copyWith(fontSize: 22, color: AppColors.text),
                ),
                const SizedBox(height: 6),
                Text('탈퇴하면 아래 내용이 모두 사라지고 되돌릴 수 없어요.', style: AxisText.caption),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      _LossRow('보유 포인트', '${formatPoints(profile.points)}P'),
                      const _LossRow('획득한 배지', '6개'),
                      _LossRow('작성한 게시물 · 댓글', '${sampleMyPosts.length}개 · ${sampleMyComments.length}개'),
                      const _LossRow('참여 중인 이벤트', '2건'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AxisSectionDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('떠나시는 이유를 알려주세요', style: AxisText.sectionTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 12),
                for (var i = 0; i < _reasons.length; i++) ...[
                  _ReasonRow(label: _reasons[i], selected: _reason == i, onTap: () => setState(() => _reason = i)),
                  if (i == _noisyAlarm && _reason == _noisyAlarm)
                    _AlarmHint(
                      onTap: () =>
                          Navigator.of(context)
                              .push(MaterialPageRoute<void>(builder: (_) => const NotificationSettingsScreen())),
                    ),
                ],
                const SizedBox(height: 8),
                Semantics(
                  checked: _confirmed,
                  label: '위 내용을 모두 확인했어요',
                  excludeSemantics: true,
                  onTap: () => setState(() => _confirmed = !_confirmed),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _confirmed = !_confirmed),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: [
                          AxisCheckbox(checked: _confirmed),
                          const SizedBox(width: 12),
                          Expanded(child: Text('위 내용을 모두 확인했어요', style: _rowText)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _rowText = TextStyle(fontSize: 16, height: 1.5, letterSpacing: -0.32, color: AppColors.text);

class _LossRow extends StatelessWidget {
  const _LossRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AxisText.body.copyWith(color: AppColors.gray06)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              AxisRadio(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: _rowText.copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "알림이 너무 많아요"를 골랐을 때 아래에 열리는 연파랑 안내 + 알림 설정 바로가기.
class _AlarmHint extends StatelessWidget {
  const _AlarmHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 32, bottom: 8),
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('필요한 알림만 받도록 바꿀 수 있어요', style: AxisText.caption.copyWith(color: AppColors.gray07)),
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 32),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '알림 설정 바로가기',
                      style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.brand),
                    ),
                    SizedBox(width: 4),
                    AxisChevronRight(size: 16, color: AppColors.brand),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
