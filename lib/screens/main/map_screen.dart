import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import 'add_schedule_screen.dart';
import 'map_ai_screen.dart';
import 'map_data.dart';
import 'map_full_screen.dart';

/// 07_09 지도 탭. 일정 목록(07_05) 화면 안에서 목록 탭과 바꿔 보여 준다(따로 화면을 열지 않는다).
/// 지도(267) 위로 그날 일정 시트가 겹친다. 동선 최적화 버튼은 화면 쪽에 떠 있고 [MapTabState.openOptimize]를 부른다.
class MapTab extends StatefulWidget {
  const MapTab({super.key, required this.day});

  /// 고른 날(11월). 23일에만 일정이 있다.
  final int day;

  @override
  State<MapTab> createState() => MapTabState();
}

const _dayNumbers = [22, 23, 24, 25, 26, 27, 28];
const _weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];

/// 작은 지도(390×267) 위 핀 왼쪽 위 좌표.
const _smallPins = {
  'home': Offset(119, 20),
  's1': Offset(255, 43),
  's2': Offset(243, 36),
  's3': Offset(220, 31),
  's4': Offset(123, 216),
  's5': Offset(148, 186),
};

class MapTabState extends State<MapTab> {
  bool _optimized = false;
  String? _selectedId = 's1';

  MapDay get _plan => MapDay.of(optimized: _optimized);
  int get _day => widget.day;
  bool get _hasPlan => _day == 23;

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _select(MapStop stop) {
    setState(() => _selectedId = stop.id);
    showPlaceDetailSheet(context, stop);
  }

  void _openAddSchedule() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddScheduleScreen()));
  }

  void _openFullMap() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => MapFullScreen(optimized: _optimized, initialId: _selectedId),
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    );
  }

  /// 화면에 떠 있는 "동선 최적화하기" 버튼이 부른다.
  void openOptimize() {
    if (!_hasPlan) {
      _toast('이 날은 최적화할 동선이 없어요.');
      return;
    }
    if (_optimized) {
      _toast('이미 AI 제안대로 바꾼 동선이에요.');
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => MapAiAnalysisScreen(onApply: _applyOptimization),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  void _applyOptimization() {
    setState(() => _optimized = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('러닝을 PM 04:30으로 옮겼어요.'),
          action: SnackBarAction(
            label: '되돌리기',
            textColor: const Color(0xFF8CC0FF),
            onPressed: () => setState(() => _optimized = false),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 지도(267) 아래로 시트가 20만큼 겹친다.
        SizedBox(
          height: 267,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned.fill(child: SvgPicture.asset('assets/icons/map_base_small.svg', fit: BoxFit.cover)),
                AnimatedOpacity(
                  opacity: _hasPlan ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_hasPlan,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 128,
                          top: 29,
                          child: SvgPicture.asset('assets/icons/map_route_main.svg', width: 138, height: 199),
                        ),
                        Positioned.fill(
                          child: MapPinLayer(day: plan, pins: _smallPins, selectedId: _selectedId, onTapPin: _select),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(right: 10, top: 10, child: _ZoomButton(onTap: _openFullMap)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 247),
          child: _ScheduleSheet(
            day: _day,
            plan: _hasPlan ? plan : null,
            selectedId: _selectedId,
            onTapStop: _select,
            onAdd: _openAddSchedule,
          ),
        ),
      ],
    );
  }
}

// ── 지도 버튼 ──────────────────────────────────────────────────────────

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '지도 크게 보기',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 3.5, offset: Offset(0, 1.7))],
          ),
          child: SvgPicture.asset('assets/icons/map_zoom.svg', width: 40, height: 40),
        ),
      ),
    );
  }
}

// ── 일정 시트 ────────────────────────────────────────────────────────────

class _ScheduleSheet extends StatelessWidget {
  const _ScheduleSheet({
    required this.day,
    required this.plan,
    required this.selectedId,
    required this.onTapStop,
    required this.onAdd,
  });

  final int day;
  final MapDay? plan;
  final String? selectedId;
  final ValueChanged<MapStop> onTapStop;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayNames[_dayNumbers.indexOf(day)];
    final plan = this.plan;
    final count = plan?.numbered.length ?? 0;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: MapColors.handle, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFDADDED))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$day일 ($weekday)',
                  style: const TextStyle(fontSize: 20, height: 1, fontWeight: FontWeight.w700, color: AppColors.gray09),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    '일정 $count건',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (plan != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        plan.summary,
                        key: ValueKey(plan.summary),
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: AppColors.body,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: plan == null
                ? _EmptyDay(key: ValueKey('empty$day'), onAdd: onAdd)
                : _Timeline(
                    key: ValueKey(plan.summary),
                    plan: plan,
                    selectedId: selectedId,
                    onTapStop: onTapStop,
                    onAdd: onAdd,
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          '이 날은 아직 일정이 없어요',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray06),
        ),
        const SizedBox(height: 6),
        const Text('일정을 추가하면 지도에 동선이 그려져요', style: TextStyle(fontSize: 13, color: AppColors.caption)),
        const SizedBox(height: 24),
        _AddScheduleButton(onTap: onAdd),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    super.key,
    required this.plan,
    required this.selectedId,
    required this.onTapStop,
    required this.onAdd,
  });

  final MapDay plan;
  final String? selectedId;
  final ValueChanged<MapStop> onTapStop;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    Object? prev;
    for (var i = 0; i < plan.entries.length; i++) {
      final e = plan.entries[i];
      if (prev != null) children.add(SizedBox(height: prev is MapStop && e is MapStop ? 10 : 20));
      if (e is MapStop) {
        children.add(
          _StopCard(
            stop: e,
            // 첫 집 카드는 지금 일정(출발 전)이라 파란 테두리.
            current: i == 0,
            showPrep: i == 0,
            onTap: () => onTapStop(e),
          ),
        );
      } else if (e is MapMove) {
        children.add(_MoveRow(move: e));
      }
      prev = e;
    }
    children
      ..add(const SizedBox(height: 20))
      ..add(_AddScheduleButton(onTap: onAdd));
    return Stack(
      children: [
        // 카드 사이를 잇는 점선(카드 아이콘 가운데).
        const Positioned(left: 21, top: 30, bottom: 93, child: _DashedLine()),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) => const CustomPaint(size: Size(2, double.infinity), painter: _DashPainter());
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.gray04
      ..strokeWidth = 2;
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawLine(Offset(1, y), Offset(1, (y + 2).clamp(0, size.height)), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StopCard extends StatelessWidget {
  const _StopCard({required this.stop, required this.current, required this.showPrep, required this.onTap});

  final MapStop stop;
  final bool current;
  final bool showPrep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = stop.listSub == null;
    final label = [stop.time, stop.title, stop.listSub].whereType<String>().join(', ');
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          decoration: BoxDecoration(
            color: MapColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: current ? AppColors.primary : Colors.transparent, width: 1.5),
          ),
          child: SizedBox(
            height: compact ? 18 : 39,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 2,
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      if (current)
                        SvgPicture.asset(
                          'assets/icons/map_home.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                        )
                      else
                        MapBadge(stop: stop),
                      SizedBox(width: current ? 11 : 9),
                      if (stop.time != null || current) ...[
                        Text(
                          stop.time ?? 'AM 07:55',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: MapColors.listGray),
                        ),
                        const SizedBox(width: 9),
                      ],
                      Flexible(
                        child: Text(
                          stop.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      if (showPrep) const _PrepChip(),
                    ],
                  ),
                ),
                if (!compact)
                  Positioned(
                    left: 29,
                    top: 23,
                    child: Text(
                      stop.listSub!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: MapColors.listGray),
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

class _PrepChip extends StatelessWidget {
  const _PrepChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/icons/map_time.svg', width: 12, height: 12),
          const SizedBox(width: 6),
          const Text(
            '준비 설정 시간(20분)',
            style: TextStyle(fontSize: 12, height: 1, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _MoveRow extends StatelessWidget {
  const _MoveRow({required this.move});

  final MapMove move;

  @override
  Widget build(BuildContext context) {
    final icon = move.mode.icon;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 20,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.white,
              alignment: Alignment.center,
              child: icon == null
                  ? const Icon(Icons.directions_walk_rounded, size: 18, color: MapColors.listGray)
                  : SvgPicture.asset(icon, width: 18, height: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(
                      text: move.mode.label,
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    TextSpan(
                      text: 'ㆍ ${move.minutes}분 소요  ',
                      style: const TextStyle(color: MapColors.listGray),
                    ),
                    TextSpan(
                      text: move.distance,
                      style: const TextStyle(color: MapColors.kmGray),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              move.route,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddScheduleButton extends StatelessWidget {
  const _AddScheduleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '이 날에 일정 추가',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: CustomPaint(
          painter: const _DashedBorderPainter(),
          child: const SizedBox(
            height: 48,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '+',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.body),
                ),
                SizedBox(width: 6),
                Text(
                  '이 날에 일정 추가',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.body),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)).deflate(0.5);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
        d += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 하단에 떠 있는 "동선 최적화하기" 알약 버튼(뒤에 파란 빛 번짐).
class MapOptimizeButton extends StatelessWidget {
  const MapOptimizeButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '동선 최적화하기',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        scale: 0.95,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0xFF005BF1)),
            boxShadow: const [BoxShadow(color: Color(0x66005BF1), blurRadius: 8)],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AiOrb(size: 22),
              SizedBox(width: 8),
              Text(
                '동선 최적화하기',
                style: TextStyle(fontSize: 16, height: 1, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
