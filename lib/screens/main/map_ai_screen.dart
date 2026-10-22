import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import 'map_data.dart';

/// AI 화면 지도(390×844) 위 24px 핀 왼쪽 위 좌표.
const _aiPins = {
  'home': Offset(105, 101),
  's1': Offset(259, 128),
  's2': Offset(246, 120),
  's3': Offset(218, 114),
  's4': Offset(104, 331),
  's5': Offset(134, 296),
};

/// AI 화면들의 지도 바탕(원래 동선 + 핀). [shift]만큼 위로 올려 그린다.
class _AiMap extends StatelessWidget {
  const _AiMap({this.shift = 0, this.showNewRoute = false, this.onTapPin});

  final double shift;
  final bool showNewRoute;
  final ValueChanged<MapStop>? onTapPin;

  @override
  Widget build(BuildContext context) {
    final day = MapDay.of(optimized: false);
    return FittedBox(
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 390,
        height: 844,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: -shift,
              width: 390,
              height: 844,
              child: SvgPicture.asset('assets/icons/map_base_ai.svg'),
            ),
            if (shift > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: shift,
                child: const ColoredBox(color: MapColors.ground),
              ),
            // 빠지는 구간(미팅 → 집 → 러닝): 회색 점선
            Positioned(
              left: 116,
              top: 112 - shift,
              child: SvgPicture.asset('assets/icons/map_route_removed.svg', width: 37, height: 232),
            ),
            if (showNewRoute)
              Positioned(
                left: 115.5,
                top: 111.5 - shift,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (_, t, child) => Opacity(opacity: t, child: child),
                  child: SvgPicture.asset('assets/icons/map_route_new.svg', width: 163, height: 233),
                ),
              ),
            Positioned.fill(
              child: MapPinLayer(
                day: day,
                pins: {for (final e in _aiPins.entries) e.key: e.value - Offset(0, shift)},
                selectedId: null,
                pinSize: 24,
                onTapPin: onTapPin ?? (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 07_09-3 AI 동선 분석 중 ──────────────────────────────────────────────

/// "동선 최적화하기"를 누르면 열린다. 약 2초 동안 분석한 뒤 제안 화면으로 바뀐다.
class MapAiAnalysisScreen extends StatefulWidget {
  const MapAiAnalysisScreen({super.key, required this.onApply, this.duration = const Duration(milliseconds: 2200)});

  /// 제안 화면에서 "제안대로 바꾸기"를 누르면 불린다.
  final VoidCallback onApply;
  final Duration duration;

  @override
  State<MapAiAnalysisScreen> createState() => _MapAiAnalysisScreenState();
}

class _MapAiAnalysisScreenState extends State<MapAiAnalysisScreen> with TickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this, duration: widget.duration)
    ..addListener(() => setState(() {}))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    });
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  static const _steps = ['오늘 일정 6개 불러오기', '시간 고정 일정 4개 확인', '이동 경로 12가지 비교 중', '가장 짧은 동선 제안하기'];
  static const _doneAt = [0.2, 0.45, 0.85, 1.01];

  @override
  void initState() {
    super.initState();
    _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    _spin.dispose();
    super.dispose();
  }

  void _finish() {
    if (!mounted) return;
    unawaited(HapticFeedback.lightImpact());
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, _, _) => MapAiSuggestionScreen(onApply: widget.onApply),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  void _cancel() {
    _progress.stop();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final t = _progress.value;
    final percent = (t * 100).clamp(0, 99).round();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay.copyWith(statusBarColor: const Color(0xFF222428)),
      child: Scaffold(
        backgroundColor: const Color(0xFF222428),
        body: Stack(
          children: [
            const Positioned.fill(child: IgnorePointer(child: _AiMap())),
            const Positioned.fill(child: ColoredBox(color: Color(0xE60B0D12))),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _OrbLoader(spin: _spin),
                      const SizedBox(height: 24),
                      Text(
                        'AI가 동선을 다시 짜고 있어요… $percent%',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text('일정이 많을수록 조금 더 걸릴 수 있어요', style: TextStyle(fontSize: 13, color: Color(0xB3FFFFFF))),
                      const SizedBox(height: 28),
                      Container(
                        width: 286,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x1FFFFFFF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < _steps.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _StepRow(
                                label: _steps[i],
                                state: t >= _doneAt[i]
                                    ? _StepState.done
                                    : (i == 0 || t >= _doneAt[i - 1])
                                    ? _StepState.now
                                    : _StepState.todo,
                                spin: _spin,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Semantics(
                        button: true,
                        label: '취소',
                        excludeSemantics: true,
                        onTap: _cancel,
                        child: Pressable(
                          onTap: _cancel,
                          child: Container(
                            width: 160,
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0x80FFFFFF)),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
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

enum _StepState { done, now, todo }

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.state, required this.spin});

  final String label;
  final _StepState state;
  final Animation<double> spin;

  @override
  Widget build(BuildContext context) {
    final icon = switch (state) {
      _StepState.done => SvgPicture.asset('assets/icons/map_step_done.svg', width: 18, height: 18),
      _StepState.todo => SvgPicture.asset('assets/icons/map_step_todo.svg', width: 18, height: 18),
      _StepState.now => RotationTransition(
        turns: spin,
        child: const CustomPaint(size: Size(18, 18), painter: _ArcPainter()),
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 18, height: 18, child: icon),
        const SizedBox(width: 10),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: state == _StepState.now ? FontWeight.w700 : FontWeight.w400,
            color: switch (state) {
              _StepState.done => const Color(0xBFFFFFFF),
              _StepState.now => Colors.white,
              _StepState.todo => const Color(0x73FFFFFF),
            },
          ),
          child: Text(label),
        ),
      ],
    );
  }
}

/// 진행 중 단계 아이콘: 옅은 원 위에 파란 4분의 1 호.
class _ArcPainter extends CustomPainter {
  const _ArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x33FFFFFF);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary;
    canvas
      ..drawOval(rect, base)
      ..drawArc(rect, -math.pi / 2, math.pi / 2, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 빛 번짐 + 회전하는 고리 + 어두운 원 + AI 오브.
class _OrbLoader extends StatelessWidget {
  const _OrbLoader({required this.spin});

  final Animation<double> spin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0x8C8B7BFF), Color(0x003D8BFF)]),
            ),
          ),
          RotationTransition(
            turns: spin,
            child: Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0xCC8B7BFF), blurRadius: 16)],
                gradient: SweepGradient(
                  colors: [
                    Color(0xFF003DAB),
                    Color(0xFF005BF1),
                    Color(0xFF136BFF),
                    Color(0xFF005FFF),
                    Color(0xFF004ED5),
                    Color(0xFF003DAB),
                  ],
                  stops: [0.0, 0.15, 0.34, 0.88, 0.93, 1.0],
                ),
              ),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(color: Color(0xFF141826), shape: BoxShape.circle),
          ),
          const AiOrb(size: 56),
        ],
      ),
    );
  }
}

// ── 07_09-3 AI 동선 제안 ────────────────────────────────────────────────

class MapAiSuggestionScreen extends StatefulWidget {
  const MapAiSuggestionScreen({super.key, required this.onApply});

  final VoidCallback onApply;

  @override
  State<MapAiSuggestionScreen> createState() => _MapAiSuggestionScreenState();
}

class _MapAiSuggestionScreenState extends State<MapAiSuggestionScreen> {
  bool? _helpful;

  void _vote(bool helpful) {
    setState(() => _helpful = _helpful == helpful ? null : helpful);
    if (_helpful != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('의견 고마워요. 다음 제안에 반영할게요.')));
    }
  }

  void _keep() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('지금 동선을 그대로 둘게요.')));
  }

  void _apply() {
    Navigator.of(context).pop();
    widget.onApply();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: MapColors.ground),
      child: Scaffold(
        backgroundColor: MapColors.ground,
        body: Stack(
          children: [
            Positioned.fill(
              child: _AiMap(shift: 40, showNewRoute: true, onTapPin: (s) => showPlaceDetailSheet(context, s)),
            ),
            // 러닝 핀 옆 시간 변경 말풍선
            const Positioned(left: 168, top: 256, child: _TimeCallout()),
            Positioned(
              left: 20,
              top: pad.top + 8,
              child: MapRoundButton(
                label: '뒤로',
                onTap: () => Navigator.of(context).maybePop(),
                child: SvgPicture.asset('assets/icons/map_back_round.svg', width: 22, height: 22),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: (pad.bottom - 9).clamp(16.0, 40.0),
              child: _SuggestionCard(helpful: _helpful, onVote: _vote, onKeep: _keep, onApply: _apply),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeCallout extends StatelessWidget {
  const _TimeCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: MapColors.textDark, borderRadius: BorderRadius.circular(8)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PM 07:30',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8B95A1),
              decoration: TextDecoration.lineThrough,
              decorationColor: Color(0xFF8B95A1),
            ),
          ),
          SizedBox(width: 4),
          Text('→', style: TextStyle(fontSize: 12, color: Color(0xFF8B95A1))),
          SizedBox(width: 4),
          Text(
            'PM 04:30',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.helpful, required this.onVote, required this.onKeep, required this.onApply});

  final bool? helpful;
  final ValueChanged<bool> onVote;
  final VoidCallback onKeep;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    Widget thumb(bool up) {
      final on = helpful == up;
      return Semantics(
        button: true,
        selected: on,
        label: up ? '도움돼요' : '별로예요',
        excludeSemantics: true,
        onTap: () => onVote(up),
        child: Pressable(
          onTap: () => onVote(up),
          scale: 0.85,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: SvgPicture.asset(
                up ? 'assets/icons/map_thumb_up.svg' : 'assets/icons/map_thumb_down.svg',
                width: 16,
                height: 17,
                colorFilter: on ? const ColorFilter.mode(AppColors.primary, BlendMode.srcIn) : null,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF005BF1), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x380057ED), blurRadius: 28, offset: Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ShaderMask(
                    shaderCallback: (r) => brandButtonGradient.createShader(r),
                    child: const Text(
                      'AI 동선 제안',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                const Spacer(),
                thumb(true),
                thumb(false),
              ],
            ),
          ),
          const Text(
            '이 순서로 움직이면 15분 아껴요',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: MapColors.textDark),
          ),
          const SizedBox(height: 6),
          const Text('러닝을 미팅 직후로 옮기는 걸 제안해요', style: TextStyle(fontSize: 14, color: MapColors.textBody)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: MapColors.cardBg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Expanded(
                  child: _CompareCol(label: '지금', value: '1시간', sub: '17.5km', highlight: false),
                ),
                SvgPicture.asset('assets/icons/map_arrow.svg', width: 20, height: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _CompareCol(label: '바꾸면', value: '45분', sub: '10.9km', highlight: true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.blue01, borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/map_reason.svg', width: 13, height: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '미팅 장소에서 한강공원까지 걸어서 5분이라,\n집에 다녀오는 버스 왕복(20분)이 빠져요.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Text(
                '바뀌는 일정 1',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7684)),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  '시간이 정해진 일정 4개는 그대로 둬요',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: MapColors.textSub),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: CubeColors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Center(
                      child: Text(
                        '5',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '러닝',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: MapColors.textDark),
                      ),
                      SizedBox(height: 2),
                      Text('미팅 장소에서 도보 5분', style: TextStyle(fontSize: 12, color: MapColors.textSub)),
                    ],
                  ),
                ),
                Text(
                  'PM 07:30',
                  style: TextStyle(
                    fontSize: 13,
                    color: MapColors.muted,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: MapColors.muted,
                  ),
                ),
                SizedBox(width: 4),
                Text('→', style: TextStyle(fontSize: 13, color: MapColors.muted)),
                SizedBox(width: 4),
                Text(
                  'PM 04:30',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              SizedBox(
                width: 128,
                child: Semantics(
                  button: true,
                  label: '그대로 둘게요',
                  excludeSemantics: true,
                  onTap: onKeep,
                  child: Pressable(
                    onTap: onKeep,
                    child: Container(
                      height: AppSizes.buttonHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.chipBorder),
                      ),
                      child: const Text(
                        '그대로 둘게요',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: MapColors.textBody),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BrandButton(label: '제안대로 바꾸기', onPressed: onApply),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'AI 제안은 참고용이에요. 바꾼 뒤에도 언제든 되돌릴 수 있어요.',
              style: TextStyle(fontSize: 12, color: MapColors.textSub),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareCol extends StatelessWidget {
  const _CompareCol({required this.label, required this.value, required this.sub, required this.highlight});

  final String label;
  final String value;
  final String sub;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: MapColors.textSub),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.primary : MapColors.textBody,
          ),
        ),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 12, color: MapColors.textSub)),
      ],
    );
  }
}
