import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'planner_widgets.dart';

/// AI 플래너 탭의 단계. 08 소개 → 0801 첫 화면 → 0802 대화.
enum AiPlannerStage { intro, home, chat }

/// AI 플래너 탭 첫 화면(피그마 08_ai온보딩 130:11845 · 0801_ai온보딩 130:11801 · 0802_ai온보딩 130:11820).
/// 탭 바 없이 화면 전체를 쓴다. 앱을 켜고 처음 들어오면 08 소개가 gif 한 바퀴(5.08초) 동안 보였다가(누르면 건너뜀) 0801로 넘어간다.
/// 0801에서 요청을 보내거나 예시 카드를 누르면 같은 화면에서 0802 대화로 바뀐다.
class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key, this.initialStage});

  /// 시작 단계. null이면 앱 실행 후 처음 한 번만 소개(08)부터, 그 뒤로는 0801부터.
  final AiPlannerStage? initialStage;

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
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _endIntro() {
    if (mounted && _stage == AiPlannerStage.intro) setState(() => _stage = AiPlannerStage.home);
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
    showAxisToast(context, agreed ? '오늘 일정표를 수정했어요' : '제안을 취소했어요', bottom: 68);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: AiPlannerBackground.top),
      child: Scaffold(
        backgroundColor: AiPlannerBackground.bottom,
        // 키패드는 아래 입력창이 직접 비켜선다(_main의 AnimatedPadding).
        resizeToAvoidBottomInset: false,
        // 피그마 08 · 0801 · 0802에는 탭 바가 없다(위 뒤로 버튼으로 나간다).
        body: AiPlannerBackground(
          lift: _stage == AiPlannerStage.intro ? 0 : MediaQuery.viewInsetsOf(context).bottom,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: _stage == AiPlannerStage.intro
                ? GestureDetector(
                    key: const ValueKey('intro'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _endIntro,
                    child: AiPlannerIntro(onFinished: _endIntro),
                  )
                : SafeArea(key: const ValueKey('main'), bottom: false, child: _main()),
          ),
        ),
      ),
    );
  }

  static const _barGap = 40.0;

  double _barBottom(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboard = mq.viewInsets.bottom;
    // 피그마 0801_ai온보딩_ 입력: 키패드 위 34에 입력창 아래가 온다.
    if (keyboard > 0) return keyboard + 34;
    return math.max(_barGap, mq.viewPadding.bottom + 6);
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
                : AiPlannerHome(
                    key: const ValueKey('home'),
                    onSuggestion: _send,
                    compact: MediaQuery.viewInsetsOf(context).bottom > 0,
                  ),
          ),
        ),
        // 피그마 0801·0802(높이 774 프레임): 입력창 아래가 화면 끝에서 40 위. 키패드가 뜨면(0801_ai온보딩_ 입력) 입력창이 키패드 위 34로 올라오고 가운데 제목은 숨는다.
        AnimatedPadding(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(20, 12, 20, _barBottom(context)),
          child: AiPromptField(controller: _input, focusNode: _focus, onSend: _send),
        ),
      ],
    );
  }
}
