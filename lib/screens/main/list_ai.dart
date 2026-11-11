import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';

/// 07_05-1 AI 일정 분석 중. 목록 위에 어두운 덮개를 깔고 [duration] 동안 단계를 진행한 뒤 true,
/// "맞추기 취소"면 null을 돌려준다.
Future<bool?> showListAiAnalyzing(BuildContext context, {Duration duration = const Duration(milliseconds: 2400)}) {
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

class _ListAiAnalyzingState extends State<ListAiAnalyzing> with SingleTickerProviderStateMixin {
  /// 화면에 보여 주는 예상 소요 시간(초).
  static const _estimate = 10;

  late final AnimationController _progress = AnimationController(vsync: this, duration: widget.duration)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      }
    })
    ..forward();

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  AxisStepState _state(double p, double start, double end) {
    if (p >= end) return AxisStepState.done;
    if (p >= start) return AxisStepState.now;
    return AxisStepState.todo;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay.copyWith(statusBarColor: Colors.transparent),
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) {
                final p = Curves.easeInOut.transform(_progress.value);
                final percent = (p * 100).round();
                final left = (_estimate * (1 - p)).ceil();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AxisAiOrb(size: 80, pulse: true),
                    const SizedBox(height: 32),
                    const Text(
                      '틀어진 일정을 다시 맞추고 있어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      left > 0 ? '$percent% · $left초 정도 걸려요' : '$percent% · 거의 다 됐어요',
                      style: TextStyle(fontSize: 12, height: 1.4, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          AxisStepItem(label: '오늘 일정 6개 불러오기', state: _state(p, 0, 0.2)),
                          const SizedBox(height: 12),
                          AxisStepItem(label: '완료한 일정 2개 확인', state: _state(p, 0.2, 0.45)),
                          const SizedBox(height: 12),
                          AxisStepItem(label: '늦어진 시간 계산 · 1시간 40분', state: _state(p, 0.45, 0.75)),
                          const SizedBox(height: 12),
                          AxisStepItem(label: '남은 일정 4개 다시 배치', state: _state(p, 0.75, 1.0)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    PressBuilder(
                      semanticLabel: '맞추기 취소',
                      onTap: () => Navigator.of(context).pop(),
                      builder: (context, pressed) => Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          '맞추기 취소',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: pressed ? 0.6 : 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 07_05-2 AI 일정 제안: 바뀐 일정 미리보기 + 아래 "AI 일정 맞추기" 패널.
/// "제안대로 맞추기"면 true, "그대로 둘게요"면 false, X·뒤로는 null을 돌려준다.
class ListAiSuggestionScreen extends StatelessWidget {
  const ListAiSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: AppColors.gray01),
      child: Scaffold(
        backgroundColor: AppColors.gray01,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AxisBackTitleBar(title: '23일(월) 바뀐 일정 미리보기'),
              const SizedBox(height: 14),
              const Expanded(child: _Preview()),
              _SuggestionPanel(
                onClose: () => Navigator.of(context).pop(),
                onKeep: () => Navigator.of(context).pop(false),
                onApply: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 바뀐 일정 미리보기(흰 바탕). 바뀐 줄은 연파랑, "지금" 표시가 끼어 있다.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const _PreviewRow(n: 1, time: '08:30 AM', title: '회사 출근', past: true),
          const _PreviewRow(
            n: 2,
            time: '11:00 AM',
            title: '기획안 제출',
            past: true,
            trailing: AxisTag('1시간 40분 늦어짐', tone: AxisTagTone.red),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(100)),
                child: const Text(
                  '지금  12:50 PM',
                  style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),
          const _PreviewRow(n: 3, time: '12:30 PM', newTime: '01:00 PM', title: '팀 점심', trailing: _ChangedTag()),
          const _PreviewRow(n: 6, time: '09:30 PM', newTime: '02:35 PM', title: '관리비 납부', trailing: _ChangedTag()),
          const _PreviewRow(n: 4, time: '03:00 PM', title: '고객사 미팅', trailing: _FixedTag()),
          const _PreviewRow(n: 5, time: '07:30 PM', title: '러닝'),
        ],
      ),
    );
  }
}

/// 연파랑 줄 위에서도 보이도록 한 단계 진한 파란 "변경" 태그.
class _ChangedTag extends StatelessWidget {
  const _ChangedTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFCFE0FF), borderRadius: BorderRadius.circular(4)),
      child: const Text(
        '변경',
        style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.brand),
      ),
    );
  }
}

class _FixedTag extends StatelessWidget {
  const _FixedTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AxisTagTone.gray.background, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AxisIcon(KitIcon.lock, size: 12, color: AxisTagTone.gray.foreground),
          const SizedBox(width: 3),
          Text(
            '고정',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: AxisTagTone.gray.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.n,
    required this.time,
    required this.title,
    this.newTime,
    this.past = false,
    this.trailing,
  });

  final int n;
  final String time;
  final String? newTime;
  final String title;
  final bool past;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final changed = newTime != null;
    return Container(
      color: changed ? AppColors.brandSoft : null,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(
              '$n',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: past ? AppColors.brandSky : AppColors.brand,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 60, child: Text(time, style: AxisText.caption)),
          if (changed) ...[
            const SizedBox(width: 4),
            Text(
              newTime!,
              style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w700, color: AppColors.brand),
            ),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: AxisText.rowTitle.copyWith(color: past ? AppColors.gray06 : AppColors.gray07),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// 아래 "AI 일정 맞추기" 패널: 제안 문구 + 바뀌는 일정 카드 + 그대로 둘게요 / 제안대로 맞추기.
class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({required this.onClose, required this.onKeep, required this.onApply});

  final VoidCallback onClose;
  final VoidCallback onKeep;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, AppSizes.ctaBottom),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3EEFF), Colors.white],
          stops: [0, 0.18],
        ),
        boxShadow: [BoxShadow(color: Color(0x1F000000), offset: Offset(0, -4), blurRadius: 24)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AxisSheetHeader(title: 'AI 일정 맞추기', ai: true, onClose: onClose),
          const SizedBox(height: 16),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '30분',
                  style: TextStyle(color: AppColors.brand),
                ),
                TextSpan(text: '만 미루면 다 지킬 수 있어요'),
              ],
            ),
            style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w700, color: AppColors.gray09),
          ),
          const SizedBox(height: 4),
          Text('기획안 제출이 늦어져 팀 점심 시간이 지났어요', style: AxisText.body.copyWith(color: AppColors.gray06)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                _ChangeRow(n: 3, title: '팀 점심', sub: '경의선숲길', from: '12:30 PM', to: '01:00 PM'),
                AxisDivider(),
                _ChangeRow(n: 6, title: '관리비 납부', sub: '미팅 가는 지하철에서 5분', from: '09:30 PM', to: '02:35 PM'),
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

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.n, required this.title, required this.sub, required this.from, required this.to});

  final int n;
  final String title;
  final String sub;
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          AxisNumberBadge(n),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AxisText.rowTitle.copyWith(color: AppColors.gray07)),
                const SizedBox(height: 2),
                Text(sub, style: AxisText.body.copyWith(color: AppColors.gray06)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                from,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.gray06,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.gray06,
                ),
              ),
              Text(
                to,
                style: const TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w700, color: AppColors.brand),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
