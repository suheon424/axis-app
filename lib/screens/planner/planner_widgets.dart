import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';

/// AI 플래너 화면 공통 배경: 위는 하늘빛, 가운데 파랑, 아래 남색으로 번지는 그라디언트 이미지(image 37).
class AiPlannerBackground extends StatelessWidget {
  const AiPlannerBackground({super.key, required this.child});

  final Widget child;

  static const top = Color(0xFFDCEAF6);
  static const bottom = Color(0xFF0D1325);
  static const asset = 'assets/images/planner/ai_bg.png';

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [bottom, bottom, CubeColors.blue],
          stops: [0, 0.245, 1],
        ),
        image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover, alignment: Alignment.topCenter),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}

/// 08_ai온보딩: axis 로고와 "무엇이든 물어보세요 / axis가 해결해드릴게요!".
class AiPlannerIntro extends StatelessWidget {
  const AiPlannerIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/planner/ai_logo.png', width: 160, height: 145),
          const SizedBox(height: 22),
          const Text('무엇이든 물어보세요', style: _title),
          const SizedBox(height: 7),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (r) => const LinearGradient(colors: [Color(0xFFA0D5FF), CubeColors.blue]).createShader(r),
            child: const Text('axis가 해결해드릴게요!', style: _title),
          ),
        ],
      ),
    );
  }
}

const _title = TextStyle(
  fontSize: 22,
  height: 1.3,
  letterSpacing: -0.22,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

/// 0801 예시 요청.
const aiSuggestions = ['오늘 일정이 교통사고나서\n완전 틀어졌어\n실행할 수 있게 수정해줘', '방문할 미술관이 휴무라서\n일정을 변경해야 해\n주변 관광지 추천해줘'];

/// 0801_ai온보딩 본문: 가운데 "어떤 계획을 도와드릴까요?"와 아래 예시 요청 카드 두 개.
class AiPlannerHome extends StatelessWidget {
  const AiPlannerHome({super.key, required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(flex: 5),
                Image.asset('assets/images/planner/ai_plus.png', width: 110, height: 110),
                const Text('어떤 계획을\n도와드릴까요?', textAlign: TextAlign.center, style: _title),
                const Spacer(flex: 6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이렇게 요청해 보세요',
                        style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < aiSuggestions.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: _SuggestionCard(
                                  text: aiSuggestions[i],
                                  onTap: () => onSuggestion(aiSuggestions[i].replaceAll('\n', ' ')),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      onTap: onTap,
      semanticLabel: text.replaceAll('\n', ' '),
      builder: (context, pressed) => Container(
        padding: const EdgeInsets.fromLTRB(15, 20, 10, 17),
        decoration: BoxDecoration(
          color: pressed ? const Color(0xFF0C2A5E) : const Color(0xFF06183A),
          backgroundBlendMode: BlendMode.screen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray02)),
      ),
    );
  }
}

/// 대화 한 줄. [answer]는 AI 제안에 대한 사용자 응답(null = 아직).
class AiChatMessage {
  AiChatMessage.user(this.text, this.time) : fromAi = false;
  AiChatMessage.ai(this.text, this.time) : fromAi = true;

  final String text;
  final DateTime time;
  final bool fromAi;
  bool? answer;
}

String _clock(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(h)}:${two(t.minute)} ${t.hour < 12 ? 'AM' : 'PM'}';
}

const _timeStyle = TextStyle(fontSize: 12, height: 1.4, color: Color(0x80FFFFFF));

/// 0802_ai온보딩 대화 목록. 아래부터 쌓인다.
class AiChatList extends StatelessWidget {
  const AiChatList({super.key, required this.messages, required this.typing, required this.onAnswer});

  final List<AiChatMessage> messages;
  final bool typing;
  final void Function(AiChatMessage message, bool agreed) onAnswer;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final m in messages) m.fromAi ? _AiBubble(message: m, onAnswer: onAnswer) : _UserBubble(message: m),
      if (typing) const _AiBubble(),
    ];
    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (_, i) => items[items.length - 1 - i],
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(_clock(message.time), style: _timeStyle),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              message.text,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// AI 답변 말풍선. [message]가 null이면 입력 중 표시.
class _AiBubble extends StatelessWidget {
  const _AiBubble({this.message, this.onAnswer});

  final AiChatMessage? message;
  final void Function(AiChatMessage message, bool agreed)? onAnswer;

  @override
  Widget build(BuildContext context) {
    final m = message;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x260D0C48), blurRadius: 10)],
          ),
          child: Image.asset('assets/images/planner/ai_avatar.png', semanticLabel: 'axis AI'),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m == null ? '' : _clock(m.time), style: _timeStyle),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: m == null
                    ? const Text('답변을 준비하고 있어요…', style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.gray06))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            m.text,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              letterSpacing: -0.32,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brand,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 280,
                            child: AxisSplitButton(
                              leftLabel: '취소',
                              rightLabel: m.answer == true ? '동의함' : '동의',
                              height: 40,
                              onLeft: m.answer == null ? () => onAnswer?.call(m, false) : null,
                              onRight: m.answer == null ? () => onAnswer?.call(m, true) : null,
                              rightEnabled: m.answer != false,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 아래 고정 입력창 "무엇을 도와드릴까요?" + 보내기(↑). 글자를 쓰면 보내기가 켜진다.
class AiPromptField extends StatelessWidget {
  const AiPromptField({super.key, required this.controller, required this.focusNode, required this.onSend});

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final ready = controller.text.trim().isNotEmpty;
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.only(left: 20, right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF005BF1), width: 2),
        gradient: const LinearGradient(colors: [Color(0xFF001841), Color(0xFF00153A), Color(0xFF021E4D)]),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              cursorColor: Colors.white,
              style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.white),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintText: '무엇을 도와드릴까요?',
                hintStyle: TextStyle(fontSize: 14, height: 1.4, color: Colors.white),
              ),
            ),
          ),
          Semantics(
            button: true,
            enabled: ready,
            label: '보내기',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: ready ? onSend : null,
              child: SizedBox(
                width: 40,
                height: 44,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: ready ? 1 : 0.5,
                  child: const Icon(Icons.arrow_upward_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
