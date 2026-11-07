import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'cal_data.dart';

/// 07_04 캘린더 · 코치마크(v2). 화면을 90% 어둡게 덮고 + 버튼(원)과 진척도 카드만 뚫어 보여 준다.
/// 가운데에는 날짜 칸 범례, 아래에는 "다시 보지 않기" + "닫기".
class CalCoachmarkOverlay extends StatefulWidget {
  const CalCoachmarkOverlay({
    super.key,
    required this.addKey,
    required this.panelKey,
    required this.cardKey,
    required this.onClose,
  });

  /// 비출 + 버튼.
  final GlobalKey addKey;

  /// 범례를 얹을 달력 판(흰 영역). 범례 제목은 판 위에서 70 아래에 놓인다.
  final GlobalKey panelKey;

  /// 비출 "계획 진척도 확인하기" 카드.
  final GlobalKey cardKey;

  /// 닫을 때 "다시 보지 않기"를 골랐는지 넘겨 준다.
  final ValueChanged<bool> onClose;

  static const dimColor = Color(0xE60A0B0F);
  static const highlight = Color(0xFF7DB8FF);

  @override
  State<CalCoachmarkOverlay> createState() => _CalCoachmarkOverlayState();
}

class _CalCoachmarkOverlayState extends State<CalCoachmarkOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  Rect? _add;
  Rect? _panel;
  Rect? _card;
  Size? _measuredFor;
  bool _dontShowAgain = false;
  bool _closing = false;

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Rect? _rectOf(GlobalKey key, RenderBox box) {
    final target = key.currentContext?.findRenderObject() as RenderBox?;
    if (target == null || !target.attached) return null;
    return MatrixUtils.transformRect(target.getTransformTo(box), Offset.zero & target.size);
  }

  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    setState(() {
      _add = _rectOf(widget.addKey, box);
      _panel = _rectOf(widget.panelKey, box);
      _card = _rectOf(widget.cardKey, box);
      _measuredFor = box.size;
    });
    _fade.forward();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    await _fade.reverse();
    widget.onClose(_dontShowAgain);
  }

  /// 아래 바("다시 보지 않기" · "닫기")는 피그마처럼 바닥에서 34 위에 둔다. 화면이 낮아
  /// 비춘 카드와 겹치면 카드 12 아래로 내려 붙이되 바닥에서 8은 띄운다.
  /// "이번 달 달성률" 안내는 카드 16 아래에 두고, 그 자리가 바와 겹치면 카드 16 위로 올린다.
  static const _barBottom = 34.0;
  static const _barHeight = 44.0;
  static const _calloutHeight = 23.0;

  double _barBottomFor(Rect? card, Size area) {
    if (card == null) return _barBottom;
    return (area.height - card.bottom - 12 - _barHeight).clamp(8.0, _barBottom);
  }

  double _cardCalloutTop(Rect card, Size area) {
    final below = card.bottom + 16;
    final barTop = area.height - _barBottomFor(card, area) - _barHeight;
    if (below + _calloutHeight <= barTop - 12) return below;
    return card.top - 16 - _calloutHeight;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (_measuredFor != size) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
    if (_measuredFor == null) return const SizedBox.expand(child: AbsorbPointer());
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = constraints.biggest;
        final circle = _add == null ? null : Rect.fromCircle(center: _add!.center, radius: 24);
        final panelTop = _panel?.top ?? 112;
        return FadeTransition(
          opacity: _fade,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 뚫린 곳도 눌리지 않게 덮개 전체가 터치를 막는다.
              AbsorbPointer(
                child: CustomPaint(
                  painter: _DimPainter(circle: circle, card: _card),
                ),
              ),
              if (circle != null)
                Positioned(
                  right: area.width - circle.left + 10,
                  top: circle.center.dy - 11,
                  child: const _Callout(before: '일정은 여기서 ', accent: '추가', after: '해요'),
                ),
              Positioned(
                left: 20,
                right: 20,
                top: panelTop + 70,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Callout(before: '날짜 색으로 ', accent: '하루 실천', after: '을 확인해요'),
                    SizedBox(height: 14),
                    _LegendCard(),
                  ],
                ),
              ),
              if (_card != null)
                Positioned(
                  left: 20,
                  right: 20,
                  top: _cardCalloutTop(_card!, area),
                  child: const _Callout(before: '이번 달 ', accent: '달성률', after: '은 여기서 확인해요'),
                ),
              Positioned(
                left: 20,
                right: 20,
                bottom: _barBottomFor(_card, area),
                child: AxisCoachmarkBottomBar(
                  dontShowAgain: _dontShowAgain,
                  onDontShowAgainChanged: (v) => setState(() => _dontShowAgain = v),
                  onClose: _close,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 흰 글자 안내(16 SemiBold), 한 낱말만 하늘색.
class _Callout extends StatelessWidget {
  const _Callout({required this.before, required this.accent, required this.after});

  final String before;
  final String accent;
  final String after;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: accent,
            style: const TextStyle(color: CalCoachmarkOverlay.highlight),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

/// Coachmark/Tooltip: 흰 카드(굴곡 16)에 날짜 칸 상태 다섯 가지.
class _LegendCard extends StatelessWidget {
  const _LegendCard();

  static const _items = [
    (AxisDayState.inProgress, 8),
    (AxisDayState.done, 9),
    (AxisDayState.scheduled, 15),
    (AxisDayState.empty, 16),
    (AxisDayState.today, 23),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (final (i, (state, day)) in _items.indexed) ...[
            if (i > 0) const SizedBox(height: 16),
            AxisDayLegendItem(state: state, label: state.label, description: state.description, day: day),
          ],
        ],
      ),
    );
  }
}

class _DimPainter extends CustomPainter {
  const _DimPainter({required this.circle, required this.card});

  final Rect? circle;
  final Rect? card;

  @override
  void paint(Canvas canvas, Size size) {
    var holes = Path();
    if (circle != null) holes.addOval(circle!);
    if (card != null) holes.addRRect(RRect.fromRectAndRadius(card!, const Radius.circular(16)));
    final path = Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), holes);
    canvas.drawPath(path, Paint()..color = CalCoachmarkOverlay.dimColor);
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.circle != circle || old.card != card;
}
