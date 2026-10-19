import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import 'list_parts.dart';

/// 07_05-1 AI 일정 분석 중. 약 2초 동안 진행한 뒤 true를 돌려주고, 취소하면 null.
Future<bool?> showListAiAnalyzing(BuildContext context, {Duration duration = const Duration(milliseconds: 2200)}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xE60B0D12),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => ListAiAnalyzing(duration: duration),
    transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
  );
}

class ListAiAnalyzing extends StatefulWidget {
  const ListAiAnalyzing({super.key, required this.duration});

  final Duration duration;

  @override
  State<ListAiAnalyzing> createState() => _ListAiAnalyzingState();
}

class _ListAiAnalyzingState extends State<ListAiAnalyzing> with TickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this, duration: widget.duration)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      }
    })
    ..forward();
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void dispose() {
    _progress.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay.copyWith(statusBarColor: const Color(0xFF0B0D12)),
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: Listenable.merge([_progress, _spin]),
          builder: (context, _) {
            final p = Curves.easeInOut.transform(_progress.value);
            final percent = (p * 100).round();
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 132,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [Color(0x8C8B7BFF), Color(0x003D8BFF)]),
                          ),
                          child: SizedBox.expand(),
                        ),
                        SizedBox.square(
                          dimension: 112,
                          child: ListAiRing(turns: _spin.value, progress: p),
                        ),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(color: Color(0xFF141826), shape: BoxShape.circle),
                        ),
                        const ListAiOrb(size: 56),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'AI가 틀어진 일정을 맞추고 있어요… $percent%',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '일정이 많을수록 조금 더 걸릴 수 있어요',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: 286,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Step(label: '오늘 일정 6개 불러오기', state: _stateFor(p, 0.0, 0.18)),
                        const SizedBox(height: 12),
                        _Step(label: '완료한 일정 2개 확인', state: _stateFor(p, 0.18, 0.4)),
                        const SizedBox(height: 12),
                        _Step(
                          label: p < 0.75 ? '늦어진 시간 계산 중 (1시간 40분)' : '늦어진 시간 계산 (1시간 40분)',
                          state: _stateFor(p, 0.4, 0.75),
                          spin: _spin.value,
                        ),
                        const SizedBox(height: 12),
                        _Step(label: '남은 일정 다시 맞추기', state: _stateFor(p, 0.75, 1.0), spin: _spin.value),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Semantics(
                    button: true,
                    label: '취소',
                    excludeSemantics: true,
                    onTap: () => Navigator.of(context).pop(),
                    child: Pressable(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 160,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _StepState _stateFor(double p, double start, double end) {
    if (p >= end && end < 1.0) return _StepState.done;
    if (p >= end) return _StepState.done;
    if (p >= start) return _StepState.now;
    return _StepState.todo;
  }
}

enum _StepState { done, now, todo }

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.state, this.spin = 0});

  final String label;
  final _StepState state;
  final double spin;

  @override
  Widget build(BuildContext context) {
    final icon = switch (state) {
      _StepState.done => SvgPicture.asset('assets/icons/list_step_done.svg', width: 18, height: 18),
      _StepState.now => RotationTransition(
        turns: AlwaysStoppedAnimation(spin),
        child: SvgPicture.asset('assets/icons/list_step_now.svg', width: 18, height: 18),
      ),
      _StepState.todo => SvgPicture.asset('assets/icons/list_step_todo.svg', width: 18, height: 18),
    };
    final style = switch (state) {
      _StepState.done => TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.75)),
      _StepState.now => const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      _StepState.todo => TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.45)),
    };
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Flexible(child: Text(label, style: style)),
      ],
    );
  }
}

/// 07_05-2 AI 일정 제안: 바뀐 일정 미리보기 + 제안 카드. "제안대로 맞추기"면 true를 돌려준다.
class ListAiSuggestionScreen extends StatefulWidget {
  const ListAiSuggestionScreen({super.key});

  @override
  State<ListAiSuggestionScreen> createState() => _ListAiSuggestionScreenState();
}

class _ListAiSuggestionScreenState extends State<ListAiSuggestionScreen> {
  static const _bg = Color(0xFFF4F5FA);

  /// 피드백: true 도움돼요, false 별로예요.
  bool? _feedback;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: _bg),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 44,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text(
                              '23일 (월) 바뀐 일정 미리보기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
                            ),
                            Positioned(
                              left: 12,
                              child: Semantics(
                                button: true,
                                label: '뒤로',
                                excludeSemantics: true,
                                onTap: () => Navigator.of(context).pop(),
                                child: Pressable(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: SvgPicture.asset('assets/icons/list_back.svg', width: 22, height: 22),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _Preview()),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _suggestionCard()),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF005BF1), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x380057ED), blurRadius: 28, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ListGradientText(
                'AI 일정 제안',
                colors: [Color(0xFF005BF1), Color(0xFF136BFF), Color(0xFF004ED5)],
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              _FeedbackButton(
                asset: 'assets/icons/list_thumb_up.svg',
                label: '도움돼요',
                selected: _feedback == true,
                onTap: () => setState(() => _feedback = _feedback == true ? null : true),
              ),
              _FeedbackButton(
                asset: 'assets/icons/list_thumb_down.svg',
                label: '별로예요',
                selected: _feedback == false,
                onTap: () => setState(() => _feedback = _feedback == false ? null : false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '점심을 30분 미루면 다 지킬 수 있어요',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          const Text('기획안 제출이 늦어져 팀 점심 시간이 지났어요', style: TextStyle(fontSize: 14, color: Color(0xFF4E5968))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Expanded(
                  child: _CompareColumn(title: '지금 그대로면', value: '5 / 6', caption: '팀 점심을 놓쳐요', highlight: false),
                ),
                SvgPicture.asset('assets/icons/list_arrow.svg', width: 20, height: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _CompareColumn(title: '바꾸면', value: '6 / 6', caption: '모두 지킬 수 있어요', highlight: true),
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
                SvgPicture.asset('assets/icons/list_reason.svg', width: 13, height: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '고객사 미팅(PM 03:00)은 그대로예요.\n관리비 납부는 미팅 가는 지하철에서 5분이면 끝나요.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Semantics(
                button: true,
                label: '그대로 둘게요',
                excludeSemantics: true,
                onTap: () => Navigator.of(context).pop(false),
                child: Pressable(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    width: 128,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.chipBorder),
                    ),
                    child: const Text(
                      '그대로 둘게요',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF4E5968)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BrandButton(label: '제안대로 맞추기', onPressed: () => Navigator.of(context).pop(true)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'AI 제안은 참고용이에요. 바꾼 뒤에도 언제든 되돌릴 수 있어요.',
              style: TextStyle(fontSize: 11, color: Color(0xFF8B95A1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({required this.asset, required this.label, required this.selected, required this.onTap});

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 32,
          child: SvgPicture.asset(
            asset,
            width: 32,
            height: 32,
            colorFilter: selected ? const ColorFilter.mode(AppColors.primary, BlendMode.srcIn) : null,
          ),
        ),
      ),
    );
  }
}

class _CompareColumn extends StatelessWidget {
  const _CompareColumn({required this.title, required this.value, required this.caption, required this.highlight});

  final String title;
  final String value;
  final String caption;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8B95A1)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.primary : const Color(0xFF4E5968),
          ),
        ),
        const SizedBox(height: 2),
        Text(caption, style: const TextStyle(fontSize: 12, color: Color(0xFF8B95A1))),
      ],
    );
  }
}

/// 바뀐 일정 미리보기 카드.
class _Preview extends StatelessWidget {
  const _Preview();

  static const _muted = Color(0xFFB0B8C1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _row(n: 1, badge: CubeColors.green, faded: true, time: 'AM 08:30', title: '회사 출근'),
          _row(
            n: 2,
            badge: CubeColors.green,
            faded: true,
            time: 'AM 11:00',
            title: '기획안 제출',
            tag: _tag('1시간 40분 늦게 끝남', const Color(0xFFFFF4E6), const Color(0xFFE8590C)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFFE5484D), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text(
                  '지금 PM 12:50',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE5484D)),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: SizedBox(height: 1, child: ColoredBox(color: Color(0xFFE5484D))),
                ),
              ],
            ),
          ),
          _row(
            n: 3,
            badge: CubeColors.green,
            changed: true,
            oldTime: 'PM 12:30',
            time: 'PM 01:00',
            title: '팀 점심',
            tag: _tag('변경', AppColors.blue01, AppColors.primary),
          ),
          _row(
            n: 6,
            badge: CubeColors.blue,
            changed: true,
            oldTime: 'PM 09:00',
            time: 'PM 02:35',
            title: '관리비 납부',
            tag: _tag('변경', AppColors.blue01, AppColors.primary),
          ),
          _row(
            n: 4,
            badge: const Color(0xFFE5484D),
            time: 'PM 03:00',
            title: '고객사 미팅',
            tag: _tag('고정', const Color(0xFFF2F4F6), const Color(0xFF6B7684), icon: 'assets/icons/list_lock.svg'),
          ),
          _row(n: 5, badge: CubeColors.orange, time: 'PM 07:30', title: '러닝'),
        ],
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg, {String? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[SvgPicture.asset(icon, width: 10, height: 10), const SizedBox(width: 3)],
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _row({
    required int n,
    required Color badge,
    required String time,
    required String title,
    bool faded = false,
    bool changed = false,
    String? oldTime,
    Widget? tag,
  }) {
    return Container(
      color: changed ? const Color(0xFFEAF2FF) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Opacity(
            opacity: faded ? 0.4 : 1,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: badge, borderRadius: BorderRadius.circular(4)),
              child: Text(
                '$n',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (oldTime != null) ...[
            Text(
              oldTime,
              style: const TextStyle(
                fontSize: 12,
                color: _muted,
                decoration: TextDecoration.lineThrough,
                decorationColor: _muted,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ] else
            Text(time, style: TextStyle(fontSize: 13, color: faded ? _muted : const Color(0xFF6B7684))),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: faded
                  ? const TextStyle(
                      fontSize: 14,
                      color: _muted,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: _muted,
                    )
                  : const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
          ),
          ?tag,
        ],
      ),
    );
  }
}
