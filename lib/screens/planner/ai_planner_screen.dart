import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'planner_widgets.dart';

/// AI 플래너 탭의 단계. 08 소개 → 0801 첫 화면 → 0802 대화.
enum AiPlannerStage { intro, home, chat }

/// AI 플래너 탭 첫 화면(피그마 08_ai온보딩 130:11845 · 0801_ai온보딩 130:11801 · 0802_ai온보딩 130:11820).
/// 앱을 켜고 처음 들어오면 08 소개가 잠깐 보였다가(누르면 건너뜀) 0801로 넘어간다.
/// 0801에서 요청을 보내거나 예시 카드를 누르면 같은 화면에서 0802 대화로 바뀐다.
class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key, this.initialStage, this.introDuration = const Duration(milliseconds: 1800)});

  /// 시작 단계. null이면 앱 실행 후 처음 한 번만 소개(08)부터, 그 뒤로는 0801부터.
  final AiPlannerStage? initialStage;
  final Duration introDuration;

  static bool _introSeen = false;

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends State<AiPlannerScreen> {
  late AiPlannerStage _stage;
  final _input = TextEditingController();
  final _focus = FocusNode();
  final List<AiChatMessage> _messages = [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage ?? (AiPlannerScreen._introSeen ? AiPlannerStage.home : AiPlannerStage.intro);
    AiPlannerScreen._introSeen = true;
    if (_stage == AiPlannerStage.intro) {
      Future.delayed(widget.introDuration, () {
        if (mounted && _stage == AiPlannerStage.intro) setState(() => _stage = AiPlannerStage.home);
      });
    }
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _back() {
    if (_stage == AiPlannerStage.chat) {
      setState(() {
        _stage = AiPlannerStage.home;
        _messages.clear();
        _typing = false;
      });
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      MainTabRouter.open(context, MainTab.home);
    }
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    _focus.unfocus();
    setState(() {
      _stage = AiPlannerStage.chat;
      _messages.add(AiChatMessage.user(text, DateTime.now()));
      _typing = true;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || !_typing) return;
      setState(() {
        _typing = false;
        _messages.add(AiChatMessage.ai('내일 하기로 했던 스터디를\n미리 예습하는건 어떨까요?\n동의 해주시면 오늘 일정표를 수정해 드릴게요.', DateTime.now()));
      });
    });
  }

  void _answer(AiChatMessage m, bool agreed) {
    setState(() => m.answer = agreed);
    showAxisToast(context, agreed ? '오늘 일정표를 수정했어요' : '제안을 취소했어요', bottom: 82 + 72);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: AiPlannerBackground.top),
      child: Scaffold(
        backgroundColor: AiPlannerBackground.bottom,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: const AxisTabBar(current: MainTab.planner),
        body: AiPlannerBackground(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: _stage == AiPlannerStage.intro
                ? GestureDetector(
                    key: const ValueKey('intro'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _stage = AiPlannerStage.home),
                    child: const AiPlannerIntro(),
                  )
                : SafeArea(key: const ValueKey('main'), bottom: false, child: _main()),
          ),
        ),
      ),
    );
  }

  Widget _main() {
    final chat = _stage == AiPlannerStage.chat;
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: AxisIconButton(icon: KitIcon.navBack, tooltip: '뒤로', onPressed: _back, color: AppColors.gray06),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: chat
                ? AiChatList(key: const ValueKey('chat'), messages: _messages, typing: _typing, onAnswer: _answer)
                : AiPlannerHome(key: const ValueKey('home'), onSuggestion: _send),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: AiPromptField(controller: _input, focusNode: _focus, onSend: _send),
        ),
      ],
    );
  }
}
