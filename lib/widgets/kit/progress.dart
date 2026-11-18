import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';

/// Progress/Mini Bar(130:10265): 64×4 가는 진행 바(바탕 #EDEEF6, 채움 파랑). [value]는 0~1.
class AxisMiniBar extends StatelessWidget {
  const AxisMiniBar({super.key, required this.value, this.width = 64, this.color = AppColors.brand});

  final double value;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Container(
      width: width,
      height: 4,
      color: AppColors.gray02,
      alignment: Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: width * v,
        height: 4,
        color: color,
      ),
    );
  }
}

/// Progress/Step Bar(130:10078): 단계 수만큼 나뉜 6px 바(사이 4). 앞 [done]개가 파랑.
/// 기본 색은 어두운 화면용(남은 단계 흰색 12%). 흰 화면에서는 [todoColor]: AppColors.gray02.
class AxisStepBar extends StatelessWidget {
  const AxisStepBar({
    super.key,
    required this.total,
    required this.done,
    this.doneColor = AppColors.brandStep,
    this.todoColor = const Color(0x1FFFFFFF),
  });

  final int total;
  final int done;
  final Color doneColor;
  final Color todoColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 6,
              decoration: BoxDecoration(
                color: i < done ? doneColor : todoColor,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

enum AxisStepState { done, now, todo }

/// Progress/Step Item(130:10200): AI 분석 단계 한 줄(어두운 바탕용).
/// done: 파란 체크 + 흰 75% / now: 도는 고리 + 흰 SemiBold / todo: 빈 고리 + 흰 45%.
class AxisStepItem extends StatelessWidget {
  const AxisStepItem({super.key, required this.label, required this.state});

  final String label;
  final AxisStepState state;

  @override
  Widget build(BuildContext context) {
    final style = switch (state) {
      AxisStepState.done => const TextStyle(fontSize: 14, height: 1.4, color: Color(0xBFFFFFFF)),
      AxisStepState.now => const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: Colors.white),
      AxisStepState.todo => const TextStyle(fontSize: 14, height: 1.4, color: Color(0x73FFFFFF)),
    };
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: switch (state) {
            AxisStepState.done => Container(
              decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
              child: const AxisIcon(KitIcon.checkWhite, size: 18),
            ),
            AxisStepState.now => const _Spinner(),
            AxisStepState.todo => Padding(
              padding: const EdgeInsets.all(1.5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x40FFFFFF), width: 1.5),
                ),
              ),
            ),
          },
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: style)),
      ],
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner();

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _c,
      child: const CustomPaint(painter: _SpinnerPainter()),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 7.5);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(rect.center, 7.5, p..color = const Color(0x33FFFFFF));
    canvas.drawArc(rect, -math.pi / 2, math.pi / 2, false, p..color = AppColors.brand);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => false;
}

/// Skeleton/Bar(130:9996): 불러오는 동안 글자 자리를 채우는 회색 막대(#EDEEF6, 굴곡 4). 천천히 깜빡인다.
class AxisSkeletonBar extends StatefulWidget {
  const AxisSkeletonBar({super.key, this.width = 120, this.height = 14});

  final double? width;
  final double height;

  @override
  State<AxisSkeletonBar> createState() => _AxisSkeletonBarState();
}

class _AxisSkeletonBarState extends State<AxisSkeletonBar> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.5).animate(_c),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: AppColors.gray02, borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

/// Pager(130:10238): ‹ 1 / 6 › 페이지 이동. 끝에서는 화살표가 흐려진다.
class AxisPager extends StatelessWidget {
  const AxisPager({super.key, required this.page, required this.count, required this.onChanged});

  /// 1부터 시작하는 현재 페이지.
  final int page;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget arrow(bool next) {
      final enabled = next ? page < count : page > 1;
      final icon = AxisIcon(KitIcon.navBack, size: 18, color: enabled ? AppColors.gray06 : AppColors.gray04);
      return Semantics(
        button: true,
        enabled: enabled,
        label: next ? '다음' : '이전',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => onChanged(page + (next ? 1 : -1)) : null,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(child: next ? Transform.flip(flipX: true, child: icon) : icon),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(false),
        const SizedBox(width: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$page',
                style: const TextStyle(color: AppColors.text),
              ),
              TextSpan(
                text: ' / $count',
                style: const TextStyle(color: AppColors.subIcon),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        arrow(true),
      ],
    );
  }
}
