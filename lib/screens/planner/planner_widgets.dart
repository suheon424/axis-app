import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';

/// AI 플래너 화면 공통 배경: 위는 하늘빛, 가운데 파랑, 아래 남색으로 번지는 그라디언트 이미지(image 37).
class AiPlannerBackground extends StatelessWidget {
  const AiPlannerBackground({super.key, required this.child, this.lift = 0});

  final Widget child;

  /// 키패드 높이. 피그마 0801_ai온보딩_ 입력처럼 배경 그림의 아래 끝을 키패드 위에 맞춰 올린다(어두운 아래쪽이 보인다).
  final double lift;

  static const top = Color(0xFFDCEAF6);
  static const bottom = Color(0xFF0D1325);
  static const asset = 'assets/images/planner/ai_bg.png';

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: lift),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, l, child) => Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: bottom),
          Positioned(
            left: 0,
            right: 0,
            top: -l,
            bottom: l,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [bottom, bottom, CubeColors.blue],
                  stops: [0, 0.245, 1],
                ),
                image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover, alignment: Alignment.topCenter),
              ),
            ),
          ),
          child!,
        ],
      ),
      child: SizedBox.expand(child: child),
    );
  }
}

/// 08_ai온보딩: 움직이는 axis 로고(kling_motion gif, 130:11852)와 "무엇이든 물어보세요 / axis가 해결해드릴게요!".
/// gif는 127장 × 0.04초 = 5.08초에 한 바퀴다. 첫 장이 화면에 그려진 순간부터 한 바퀴가 끝나면 [onFinished]를 부른다.
/// gif가 1초 안에 뜨지 않으면(느린 기기·테스트) 그때부터 센다.
class AiPlannerIntro extends StatefulWidget {
  const AiPlannerIntro({super.key, this.onFinished});

  final VoidCallback? onFinished;

  static const asset = 'assets/images/planner/ai_intro.gif';
  static const loop = Duration(milliseconds: 5080);

  @override
  State<AiPlannerIntro> createState() => _AiPlannerIntroState();
}

class _AiPlannerIntroState extends State<AiPlannerIntro> {
  Timer? _fallback;
  Timer? _end;

  @override
  void initState() {
    super.initState();
    _fallback = Timer(const Duration(seconds: 1), _start);
  }

  void _start() {
    _fallback?.cancel();
    if (_end != null) return;
    _end = Timer(AiPlannerIntro.loop, () => widget.onFinished?.call());
  }

  @override
  void dispose() {
    _fallback?.cancel();
    _end?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AiPlannerIntro.asset,
            width: 160,
            height: 145,
            fit: BoxFit.fill,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, _) {
              if (frame != null) WidgetsBinding.instance.addPostFrameCallback((_) => _start());
              return child;
            },
          ),
          const SizedBox(height: 23),
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
  const AiPlannerHome({super.key, required this.onSuggestion, this.compact = false});

  final ValueChanged<String> onSuggestion;

  /// 키패드가 떠 있을 때(피그마 0801_ai온보딩_ 입력): 가운데 플러스·제목을 숨기고 예시 카드만 입력창 위에 둔다.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                if (compact)
                  const Spacer()
                else ...[
                  const Spacer(flex: 5),
                  // Frame 237 1(130:11818): 투명 바탕 플러스, 피그마에서 100 → 60으로 줄였다(제목까지 8).
                  // 제목 자리는 그대로 두고 로고만 작아지게 위를 37 비운다.
                  const SizedBox(height: 37),
                  Image.asset('assets/images/planner/ai_plus.png', width: 60, height: 60),
                  const SizedBox(height: 8),
                  const Text('어떤 계획을\n도와드릴까요?', textAlign: TextAlign.center, style: _title),
                  const Spacer(flex: 6),
                ],
                Padding(
                  // 예시 카드 아래와 입력창 위 사이 30(피그마 0801: 카드 끝 654, 입력창 684). 폭은 입력창과 같은 350.
                  padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 16, AppSizes.sidePadding, 18),
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
  AiChatMessage.user(this.text, this.time) : fromAi = false, done = false;
  AiChatMessage.ai(this.text, this.time) : fromAi = true, done = false;

  /// 0802_ai온보딩 · 동의함: 동의한 뒤 AI가 "오늘 일정표를 수정했어요" 하고 바뀐 일정을 알려 주는 말풍선.
  AiChatMessage.aiDone(this.time) : text = '', fromAi = true, done = true;

  final String text;
  final DateTime time;
  final bool fromAi;
  final bool done;
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
      for (final m in messages)
        m.fromAi ? _AiBubble(key: ObjectKey(m), message: m, onAnswer: onAnswer) : _UserBubble(message: m),
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
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
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
  const _AiBubble({super.key, this.message, this.onAnswer});

  final AiChatMessage? message;
  final void Function(AiChatMessage message, bool agreed)? onAnswer;

  @override
  Widget build(BuildContext context) {
    final m = message;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI/Orb(256:10421) 28: 피그마에서 내보낸 그림 그대로(남색 원 + 안쪽 빛 + 그라디언트 로고).
        Image.asset('assets/images/planner/ai_orb.png', width: 28, height: 28, semanticLabel: 'axis AI'),
        const SizedBox(width: 10),
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
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: m == null
                    ? const Text('답변을 준비하고 있어요…', style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.gray06))
                    : m.done
                    ? const _AiDoneBody()
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
                          _AgreeButtons(
                            answer: m.answer,
                            onCancel: () => onAnswer?.call(m, false),
                            onAgree: () => onAnswer?.call(m, true),
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

/// 취소 | 동의 버튼(2Primary, 280×40). 동의를 누르면 파란 사선이 오른쪽에서 왼쪽으로 버튼 전체를 채우고
/// 0802_ai온보딩 · 동의함의 "동의함" 버튼(280×40, 굴곡 8, #0039B3, 가운데 16 SemiBold 흰 글자)이 된다.
class _AgreeButtons extends StatefulWidget {
  const _AgreeButtons({required this.answer, required this.onCancel, required this.onAgree});

  final bool? answer;
  final VoidCallback onCancel;
  final VoidCallback onAgree;

  @override
  State<_AgreeButtons> createState() => _AgreeButtonsState();
}

class _AgreeButtonsState extends State<_AgreeButtons> with SingleTickerProviderStateMixin {
  static const agreed = Color(0xFF0039B3);
  late final _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    value: widget.answer == true ? 1 : 0,
  );

  @override
  void didUpdateWidget(_AgreeButtons old) {
    super.didUpdateWidget(old);
    if (widget.answer == true && old.answer != true) _fill.forward(from: 0);
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.answer;
    return SizedBox(
      width: 280,
      height: 40,
      child: AnimatedBuilder(
        animation: _fill,
        builder: (context, _) {
          final t = Curves.easeInOutCubic.transform(_fill.value);
          if (a == true && _fill.isCompleted) return _done(1);
          return Stack(
            fit: StackFit.expand,
            children: [
              AxisSplitButton(
                leftLabel: '취소',
                rightLabel: '동의',
                height: 40,
                onLeft: a == null ? widget.onCancel : null,
                onRight: a == null ? widget.onAgree : null,
                rightEnabled: a != false,
              ),
              if (a == true)
                IgnorePointer(
                  child: CustomPaint(
                    painter: _SweepFillPainter(t),
                    child: _done(((t - 0.55) / 0.45).clamp(0.0, 1.0), filled: false),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _done(double opacity, {bool filled = true}) => Container(
    decoration: filled ? BoxDecoration(color: agreed, borderRadius: BorderRadius.circular(8)) : null,
    alignment: Alignment.center,
    child: Opacity(
      opacity: opacity,
      child: const Text(
        '동의함',
        style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    ),
  );
}

/// 버튼 전체(굴곡 8)를 #0039B3 사선 채움으로 덮는다. [t]=0 오른쪽 밖 → 1 왼쪽 끝까지.
class _SweepFillPainter extends CustomPainter {
  const _SweepFillPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final clip = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)));
    paintEnableFill(canvas, size, clip, t, _AgreeButtonsState.agreed, size.height * 35.5 / 52);
  }

  @override
  bool shouldRepaint(_SweepFillPainter old) => old.t != t;
}

/// 0802_ai온보딩 · 동의함 "AI follow-up" 말풍선 안: 완료 아이콘(20) · 두 줄 안내(16 SemiBold, 첫 줄 파랑) ·
/// 바뀐 일정 줄(#F4F5FA, 굴곡 8, 안쪽 12/14, 07:00 PM · 스터디 예습 · 보기 태그).
class _AiDoneBody extends StatelessWidget {
  const _AiDoneBody();

  @override
  Widget build(BuildContext context) {
    const strong = TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600);
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/images/planner/ai_done.svg', width: 20, height: 20),
          const SizedBox(height: 12),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '오늘 일정표를 수정했어요.\n',
                  style: TextStyle(color: AppColors.brand),
                ),
                TextSpan(
                  text: '19:00에 스터디 예습 1시간을 넣었어요.',
                  style: TextStyle(color: Color(0xFF181920)),
                ),
              ],
            ),
            style: strong,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 47),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: AppColors.searchBg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Text(
                  '07:00 PM',
                  style: TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.gray06),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '스터디 예습',
                    style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.gray07),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFD3EBFF), borderRadius: BorderRadius.circular(4)),
                  child: const Text(
                    '보기',
                    style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.brand),
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

/// 아래 고정 입력창 "무엇을 도와드릴까요?" + 보내기(↑). 글자를 쓰면 보내기가 켜진다.
class AiPromptField extends StatefulWidget {
  const AiPromptField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.spin = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  /// 테두리(선)의 각도 그라디언트를 [spinDuration]마다 360° 돌릴지. 채우기는 그대로.
  final bool spin;

  static const spinDuration = Duration(milliseconds: 3200);

  /// 테스트에서 끝없는 회전 때문에 pumpAndSettle이 멈추지 않게 끌 수 있다.
  @visibleForTesting
  static bool spinEnabled = true;

  @override
  State<AiPromptField> createState() => _AiPromptFieldState();
}

class _AiPromptFieldState extends State<AiPromptField> with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(vsync: this, duration: AiPromptField.spinDuration);

  @override
  void initState() {
    super.initState();
    if (_spinning) _spin.repeat();
  }

  bool get _spinning => widget.spin && AiPromptField.spinEnabled;

  @override
  void didUpdateWidget(AiPromptField old) {
    super.didUpdateWidget(old);
    if (_spinning && !_spin.isAnimating) _spin.repeat();
    if (!widget.spin && _spin.isAnimating) _spin.stop();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  TextEditingController get controller => widget.controller;
  FocusNode get focusNode => widget.focusNode;
  VoidCallback get onSend => widget.onSend;

  @override
  Widget build(BuildContext context) {
    final ready = controller.text.trim().isNotEmpty;
    return CustomPaint(
      painter: _PromptGradientPainter(_spin),
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.only(left: 20, right: 6),
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
                    opacity: 1, // 피그마: 비어 있어도 흰 화살표
                    child: const Icon(Icons.arrow_upward_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frame 105(입력창, 0801_ai온보딩): 채우기 검정 90%, 반지름 12, 테두리 안쪽 2의 선형 그라디언트
/// (#1A3466 14.5% · #003DAB 40% · #005FFF 65% · #A0D5FF 100%, 가운데 → 오른쪽 끝), 안쪽 그림자 #0141B6 x −10 흐림 15.
/// 밝은 쪽(오른쪽)과 안쪽 그림자가 함께 [turns]만큼 테두리를 따라 360° 돈다.
class _PromptGradientPainter extends CustomPainter {
  _PromptGradientPainter(this.turns) : super(repaint: turns);

  final Animation<double> turns;

  // 피그마 테두리 색(#A0D5FF → #005FFF → #003DAB → #1A3466)을 밝은 쪽(0°)에서 양옆으로 대칭으로 둘렀다.
  static const _light = Color(0xFFA0D5FF), _blue = Color(0xFF005FFF), _deep = Color(0xFF003DAB);
  static const _dark = Color(0xFF1A3466);
  static const _sweepColors = [_light, _blue, _deep, _dark, _dark, _deep, _blue, _light];
  static const _sweepStops = [0.0, 0.1, 0.22, 0.34, 0.66, 0.78, 0.9, 1.0];
  static const _shadow = Color(0xFF0141B6);
  static const _shadowOffset = 10.0;
  static const _shadowBlur = 15.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    final a = turns.value * 2 * math.pi;
    final dir = Offset(math.cos(a), math.sin(a)); // 밝은 쪽 방향(박스 비율 공간)
    final center = size.center(Offset.zero);

    canvas.drawRRect(rrect, Paint()..color = Colors.black.withValues(alpha: 0.9));

    // 안쪽 그림자: 박스 밖을 칠한 모양을 밝은 쪽 반대로 10 밀어 흐리게 그리고, 박스 안만 남긴다.
    canvas.save();
    canvas.clipRRect(rrect);
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rrect.outerRect.inflate(_shadowBlur * 3))
      ..addRRect(rrect.shift(dir * -_shadowOffset));
    canvas.drawPath(
      outside,
      Paint()
        ..color = _shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _shadowBlur / 2),
    );
    canvas.restore();

    // 테두리: 가운데에서 [a] 방향 한쪽만 밝고 양옆으로 갈수록 어두워지는 각도 그라디언트가 통째로 돈다.
    // 가로로 긴 상자라 각도를 상자 비율 공간에서 잰다: 45°면 밝은 곳이 오른쪽 위 모서리, 안쪽 그림자가 가장 짙은 곳과
    // 같은 자리에 와서 둘이 한 바퀴를 같은 시간에 같은 자리로 돈다.
    final spin = Matrix4.translationValues(center.dx, center.dy, 0)
      ..scaleByDouble(size.width / size.height, 1, 1, 1)
      ..rotateZ(a)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    canvas.drawRRect(
      rrect.deflate(1),
      Paint()
        ..shader = ui.Gradient.sweep(center, _sweepColors, _sweepStops, TileMode.clamp, 0, 2 * math.pi, spin.storage)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_PromptGradientPainter old) => false;
}
