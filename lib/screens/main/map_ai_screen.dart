import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import 'map_data.dart';

const _darkBg = Color(0xFF222428);

// ── 07_09-3 AI 동선 분석 중 ──────────────────────────────────────────────

/// "동선 최적화하기"를 누르면 열린다. 잠시 분석한 뒤 제안 화면(07_09-3 AI 동선 제안)으로 바뀐다.
class MapAiAnalysisScreen extends StatefulWidget {
  const MapAiAnalysisScreen({super.key, required this.onApply, this.duration = const Duration(milliseconds: 2200)});

  /// 제안 화면에서 "제안대로 맞추기"를 누르면 불린다.
  final VoidCallback onApply;
  final Duration duration;

  @override
  State<MapAiAnalysisScreen> createState() => _MapAiAnalysisScreenState();
}

class _MapAiAnalysisScreenState extends State<MapAiAnalysisScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this, duration: widget.duration)
    ..addListener(() => setState(() {}))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    });

  static const _steps = ['오늘 일정 6개 불러오기', '시간 고정 일정 4개 확인', '이동 경로 12가지 비교', '가장 짧은 동선 제안'];
  static const _doneAt = [0.2, 0.45, 0.85, 1.01];

  @override
  void initState() {
    super.initState();
    _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
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
    final seconds = ((1 - t) * 28).ceil().clamp(1, 28);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay.copyWith(statusBarColor: _darkBg),
      child: Scaffold(
        backgroundColor: _darkBg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  child: MapCanvas(
                    asset: 'assets/icons/map_base_ai.svg',
                    size: Size(390, 844),
                    pins: aiMapPins,
                    route: [],
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: ColoredBox(color: Color(0xD91F2027))),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 22),
                  const AxisAiOrb(size: 80, pulse: true),
                  const SizedBox(height: 20),
                  const Text(
                    'AI가 동선을 다시 짜고 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percent% · $seconds초 정도 걸려요',
                    style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xBFFFFFFF)),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 35),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        for (var i = 0; i < _steps.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          AxisStepItem(
                            label: _steps[i],
                            state: t >= _doneAt[i]
                                ? AxisStepState.done
                                : (i == 0 || t >= _doneAt[i - 1])
                                ? AxisStepState.now
                                : AxisStepState.todo,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PressBuilder(
                    semanticLabel: '맞추기 취소',
                    onTap: _cancel,
                    builder: (context, pressed) => Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      alignment: Alignment.center,
                      child: Text(
                        '맞추기 취소',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: pressed ? const Color(0x99FFFFFF) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 07_09-3 AI 동선 제안 ────────────────────────────────────────────────

/// 분석이 끝나면 보이는 제안: 바뀐 동선(파랑) · 빠지는 구간(회색 점선) · 아래 AI 시트.
class MapAiSuggestionScreen extends StatelessWidget {
  const MapAiSuggestionScreen({super.key, required this.onApply});

  final VoidCallback onApply;

  void _keep(BuildContext context) {
    Navigator.of(context).pop();
    showAxisToast(context, '지금 동선을 그대로 둘게요.', bottom: 82);
  }

  void _apply(BuildContext context) {
    Navigator.of(context).pop();
    onApply();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final plan = MapDay.of(optimized: true);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: mapGround),
      child: Scaffold(
        backgroundColor: mapGround,
        body: Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 390,
                  height: 844,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 크게 보기 지도를 조금 확대해 동선이 시트 위에 오도록 옮겨 그린다.
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Transform(
                          transform: Matrix4.translationValues(-9.9, -76.2, 0)
                            ..multiply(Matrix4.diagonal3Values(1.065, 1.065, 1)),
                          child: MapCanvas(
                            asset: 'assets/icons/map_base_big.svg',
                            size: const Size(390, 844),
                            pins: bigMapPins,
                            day: plan,
                            route: plan.route,
                            removed: const ['s4', 'home'],
                            highlightId: 's5',
                            onTapPin: (s) => showPlaceDetailSheet(context, s),
                          ),
                        ),
                      ),
                      const Positioned(left: 148, top: 441, child: _TimeCallout()),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(left: 20, top: pad.top + 11, child: AxisIconButton.back(floating: true)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _SuggestionSheet(onKeep: () => _keep(context), onApply: () => _apply(context)),
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
      constraints: const BoxConstraints(minHeight: 27),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.gray07, borderRadius: BorderRadius.circular(4)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('07:30 PM', style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray05)),
          SizedBox(width: 6),
          Text('→', style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray05)),
          SizedBox(width: 6),
          Text(
            '04:30 PM',
            style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SuggestionSheet extends StatelessWidget {
  const _SuggestionSheet({required this.onKeep, required this.onApply});

  final VoidCallback onKeep;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.brandSoft, Colors.white],
          stops: [0, 0.35],
        ),
        boxShadow: [BoxShadow(color: Color(0x1F000000), offset: Offset(0, -4), blurRadius: 24)],
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, AppSizes.ctaBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AxisSheetHeader(title: 'AI 동선 맞추기', ai: true, onClose: onKeep),
          const SizedBox(height: 16),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: '15분',
                  style: TextStyle(color: AppColors.brand),
                ),
                TextSpan(text: ' 더 여유로워져요'),
              ],
            ),
            style: AxisText.title18.copyWith(color: AppColors.gray07),
          ),
          const SizedBox(height: 4),
          Text('러닝을 미팅 직후로 옮기면 이동이 6.6km 줄어요', style: AxisText.body.copyWith(color: AppColors.gray06)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const AxisNumberBadge(5),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('러닝', style: AxisText.rowTitle.copyWith(color: AppColors.gray07)),
                      const Text('미팅 장소에서 도보 5분', style: AxisText.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '07:30 PM',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.gray06,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.gray06,
                      ),
                    ),
                    Text(
                      '04:30 PM',
                      style: TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w700, color: AppColors.brand),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AxisSplitButton(leftLabel: '그대로 둘게요', rightLabel: '제안대로 맞추기', onLeft: onKeep, onRight: onApply),
        ],
      ),
    );
  }
}
