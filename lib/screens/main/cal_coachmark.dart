import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'cal_widgets.dart';

/// 코치마크 한 단계: 비출 대상과 안내 문구.
class CalCoachStep {
  const CalCoachStep({
    required this.target,
    required this.title,
    required this.body,
    this.isCell = true,
    this.cardAbove = false,
    this.previewDate,
    this.nextLabel = '다음',
  });

  final GlobalKey target;
  final String title;
  final String body;

  /// 날짜 칸이면 칸(40) 둘레로 55×55를 비춘다. 아니면 대상 줄 전체(좌우 8)를 비춘다.
  final bool isCell;

  /// 안내 카드를 대상 위에 놓을지.
  final bool cardAbove;

  /// 길게 누르기 미리보기 말풍선을 함께 보여 줄 날짜.
  final DateTime? previewDate;
  final String nextLabel;
}

/// 07_03 캘린더 코치마크(1/4~4/4). 화면을 72% 검정으로 덮고 대상만 둥글게 뚫어 흰 테두리로 비춘다.
/// "다음"이나 어두운 곳을 누르면 넘어가고, 마지막 단계·"건너뛰기"는 닫는다.
class CalCoachmarkOverlay extends StatefulWidget {
  const CalCoachmarkOverlay({super.key, required this.steps, required this.onClose});

  final List<CalCoachStep> steps;
  final VoidCallback onClose;

  @override
  State<CalCoachmarkOverlay> createState() => _CalCoachmarkOverlayState();
}

class _CalCoachmarkOverlayState extends State<CalCoachmarkOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  int _step = 0;
  List<Rect?>? _targets;
  Size? _measuredFor;
  bool _closing = false;

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final rects = <Rect?>[];
    for (final s in widget.steps) {
      final target = s.target.currentContext?.findRenderObject() as RenderBox?;
      if (target == null || !target.attached) {
        rects.add(null);
        continue;
      }
      rects.add(MatrixUtils.transformRect(target.getTransformTo(box), Offset.zero & target.size));
    }
    setState(() {
      _targets = rects;
      _measuredFor = box.size;
    });
    _fade.forward();
  }

  Rect _hole(int i, Size size) {
    final t = _targets![i] ?? Rect.fromCenter(center: size.center(Offset.zero), width: 0, height: 0);
    if (widget.steps[i].isCell) return Rect.fromCenter(center: t.center, width: 55, height: 55);
    return Rect.fromLTRB(8, t.top - 2, size.width - 8, t.top + 48);
  }

  void _next() {
    if (_closing) return;
    if (_step >= widget.steps.length - 1) {
      _close();
    } else {
      setState(() => _step++);
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    await _fade.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (_targets == null || _measuredFor != size) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
    if (_targets == null) {
      return const SizedBox.expand(child: AbsorbPointer());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = constraints.biggest;
        final hole = _hole(_step, area);
        final step = widget.steps[_step];
        return FadeTransition(
          opacity: _fade,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                label: '코치마크 배경, 눌러서 다음',
                button: true,
                onTap: _next,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _next,
                  child: TweenAnimationBuilder<Rect?>(
                    tween: RectTween(end: hole),
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeInOutCubic,
                    builder: (context, rect, _) => CustomPaint(painter: _DimPainter(rect ?? hole)),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
                child: Stack(
                  key: ValueKey(_step),
                  fit: StackFit.expand,
                  children: [
                    if (step.previewDate != null)
                      Builder(
                        builder: (context) {
                          final cell = Rect.fromCenter(center: hole.center, width: 40, height: 40);
                          final origin = calPreviewOrigin(cell, area.width);
                          final dx = cell.center.dx - (origin.dx + CalDayPreview.width / 2);
                          return Positioned(
                            left: origin.dx,
                            top: origin.dy,
                            child: IgnorePointer(
                              child: CalDayPreview(date: step.previewDate!, pointerDx: dx),
                            ),
                          );
                        },
                      ),
                    Positioned(
                      left: 20,
                      right: 20,
                      top: step.cardAbove ? null : hole.bottom + 20,
                      bottom: step.cardAbove ? area.height - hole.top + 21 : null,
                      child: _CoachCard(
                        index: _step,
                        count: widget.steps.length,
                        step: step,
                        onNext: _next,
                        onSkip: _close,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DimPainter extends CustomPainter {
  const _DimPainter(this.hole);

  final Rect hole;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(hole, const Radius.circular(10));
    final path = Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(rrect));
    canvas.drawPath(path, Paint()..color = const Color(0xB8000000));
    canvas.drawRRect(
      rrect.deflate(1),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.hole != hole;
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.index,
    required this.count,
    required this.step,
    required this.onNext,
    required this.onSkip,
  });

  final int index;
  final int count;
  final CalCoachStep step;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1} / $count',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF9EC2FF)),
          ),
          const SizedBox(height: 8),
          Text(
            step.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(step.body, style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFD1D6DB))),
          const SizedBox(height: 28),
          Row(
            children: [
              Semantics(
                button: true,
                label: '건너뛰기',
                excludeSemantics: true,
                onTap: onSkip,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSkip,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFFB0B8C1)),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: step.nextLabel,
                excludeSemantics: true,
                onTap: onNext,
                child: GestureDetector(
                  onTap: onNext,
                  child: Container(
                    width: 96,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      step.nextLabel,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
