import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/browser_keyboard.dart';
import '../../widgets/kit/kit.dart';
import 'planner_widgets.dart';

/// AI 플래너 탭의 단계. 08 소개 → 0801 첫 화면 → 0802 대화.
enum AiPlannerStage { intro, home, chat }

/// AI 플래너 탭 첫 화면(피그마 08_ai온보딩 130:11845 · 0801_ai온보딩 130:11801 · 0802_ai온보딩 130:11820).
/// 탭 바 없이 화면 전체를 쓴다. 앱을 켜고 처음 들어오면 08 소개가 gif 한 바퀴(5.08초) 동안 보였다가(누르면 건너뜀) 0801로 넘어간다.
/// 0801에서 요청을 보내거나 예시 카드를 누르면 같은 화면에서 0802 대화로 바뀐다.
class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key, this.initialStage, this.simulateKeyboard});

  /// 입력창을 눌렀을 때 피그마 키패드 그림(0801_ai온보딩_ 입력의 IMG_1387)을 대신 띄울지.
  /// null이면 진짜 키패드가 없는 컴퓨터 브라우저에서만 띄운다(폰은 진짜 키패드를 쓴다).
  final bool? simulateKeyboard;

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
    _focus.addListener(() => setState(() {}));
    browserKeyboardInset.addListener(_onBrowserKeyboard);
  }

  void _onBrowserKeyboard() => setState(() {});

  bool get _simulate =>
      widget.simulateKeyboard ??
      (kIsWeb && defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android);

  /// 피그마 키패드 그림 390×379.
  static const _fakeKeyboardAspect = 390 / 379;

  /// 지금 화면 아래를 덮는 키패드 높이. 진짜 키패드가 없으면(컴퓨터 브라우저) 입력 중일 때 그림 키패드 높이.
  double _keyboard(BuildContext context) {
    // 아이폰 사파리는 viewInsets를 0으로 주는 일이 많아 브라우저가 잰 키패드 높이도 함께 본다.
    final browser = _focus.hasFocus ? browserKeyboardInset.value : 0.0;
    final real = math.max(MediaQuery.viewInsetsOf(context).bottom, browser);
    if (real > 0) return real;
    if (_simulate && _focus.hasFocus && _stage != AiPlannerStage.intro) {
      return MediaQuery.sizeOf(context).width / _fakeKeyboardAspect;
    }
    return 0;
  }

  @override
  void dispose() {
    browserKeyboardInset.removeListener(_onBrowserKeyboard);
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
          lift: _stage == AiPlannerStage.intro ? 0 : _keyboard(context),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: _stage == AiPlannerStage.intro
                ? GestureDetector(
                    key: const ValueKey('intro'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _endIntro,
                    child: AiPlannerIntro(onFinished: _endIntro),
                  )
                : Stack(
                    key: const ValueKey('main'),
                    children: [
                      SafeArea(bottom: false, child: _main()),
                      if (_simulate) _fakeKeyboardView(context),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  static const _barGap = 40.0;

  double _barBottom(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboard = _keyboard(context);
    // 피그마 0801_ai온보딩_ 입력: 키패드 위 34에 입력창 아래가 온다.
    if (keyboard > 0) return keyboard + 34;
    return math.max(_barGap, mq.viewPadding.bottom + 6);
  }

  /// 컴퓨터 브라우저용 그림 키패드. 입력 중이면 아래에서 올라온다. "완료"는 입력을 끝내고 "전송"은 보낸다.
  /// 누르는 동안 입력창 포커스가 풀리지 않게 TextFieldTapRegion으로 감싼다.
  Widget _fakeKeyboardView(BuildContext context) {
    // 진짜 키패드가 잡히면(폰 브라우저) 그림은 띄우지 않는다.
    final realKeyboard = math.max(MediaQuery.viewInsetsOf(context).bottom, browserKeyboardInset.value) > 0;
    final shown = _focus.hasFocus && _stage != AiPlannerStage.intro && !realKeyboard;
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / 390;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: !shown,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          offset: shown ? Offset.zero : const Offset(0, 1),
          child: TextFieldTapRegion(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final p = d.localPosition / scale;
                if (p.dy < 44 && p.dx > 300) {
                  _focus.unfocus(); // 완료
                } else if (p.dy > 258 && p.dy < 304 && p.dx > 294) {
                  _send(); // 전송
                }
              },
              child: Image.asset(
                'assets/images/planner/ai_keyboard.png',
                width: width,
                height: width / _fakeKeyboardAspect,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
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
          height: 50,
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
                : AiPlannerHome(key: const ValueKey('home'), onSuggestion: _send, compact: _keyboard(context) > 0),
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
