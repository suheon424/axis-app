import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'add_schedule_screen.dart';
import 'map_ai_screen.dart';
import 'map_data.dart';
import 'map_full_screen.dart';

/// 지도 영역의 상태(07_09 지도 / 07_09 지도 · 오류).
enum MapLoadStatus { ready, loading, error }

/// 07_09 지도 탭. 일정 목록 화면 안에서 목록 탭과 바꿔 보여 준다(따로 화면을 열지 않는다).
/// 세그먼트·주간 달력 아래에 지도(267)를 두고, 그 위로 그날 타임라인 시트가 겹친다.
/// 동선 최적화 버튼은 목록 화면 쪽에 떠 있고 [MapTabState.openOptimize]를 부른다.
///
/// 데모: 지도를 길게 누르면 오류 상태(07_09 지도 · 오류)로 바뀌고 "다시 시도"로 돌아온다.
/// 위치 권한 요청(07_09 지도 · 위치 권한 요청)은 처음 동선 최적화를 누를 때, 또는 [askLocationOnOpen]이면 열 때 뜬다.
class MapTab extends StatefulWidget {
  const MapTab({
    super.key,
    required this.day,
    this.initialStatus = MapLoadStatus.ready,
    this.askLocationOnOpen = false,
  });

  /// 고른 날(11월). 23일에만 일정이 있다.
  final int day;
  final MapLoadStatus initialStatus;
  final bool askLocationOnOpen;

  @override
  State<MapTab> createState() => MapTabState();
}

const _dayNumbers = [22, 23, 24, 25, 26, 27, 28];
const _weekdayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];

class MapTabState extends State<MapTab> {
  bool _optimized = false;
  String? _selectedId;
  late MapLoadStatus _status = widget.initialStatus;

  /// null = 아직 묻지 않음.
  bool? _locationGranted;
  Timer? _retry;

  MapDay get _plan => MapDay.of(optimized: _optimized);
  bool get _hasPlan => widget.day == 23;

  @override
  void initState() {
    super.initState();
    if (widget.askLocationOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _askLocation();
      });
    }
  }

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }

  Future<void> _askLocation() async {
    final ok = await showAxisConfirm(
      context,
      title: '위치 권한이 필요해요',
      message: '내 위치를 기준으로 동선을 추천해 드려요.',
      confirmLabel: '허용하기',
      otherLabel: '나중에',
      destructive: false,
    );
    if (!mounted) return;
    setState(() => _locationGranted = ok ?? false);
  }

  void _select(MapStop stop) {
    setState(() => _selectedId = stop.id);
    showPlaceDetailSheet(context, stop);
  }

  void _openAddSchedule() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddScheduleScreen()));
  }

  void _toggleError() => setState(() => _status = MapLoadStatus.error);

  void _reload() {
    setState(() => _status = MapLoadStatus.loading);
    _retry?.cancel();
    _retry = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _status = MapLoadStatus.ready);
    });
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
  Future<void> openOptimize() async {
    if (!_hasPlan) {
      showAxisToast(context, '이 날은 맞출 동선이 없어요.', bottom: 82);
      return;
    }
    if (_optimized) {
      showAxisToast(context, '이미 AI 제안대로 맞춘 동선이에요.', bottom: 82);
      return;
    }
    if (_locationGranted == null) {
      await _askLocation();
      if (!mounted) return;
    }
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => MapAiAnalysisScreen(onApply: _applyOptimization),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  void _applyOptimization() {
    setState(() => _optimized = true);
    showAxisToast(
      context,
      '러닝을 04:30 PM으로 옮겼어요',
      actionLabel: '되돌리기',
      onAction: () {
        if (mounted) setState(() => _optimized = false);
      },
      bottom: 82,
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 지도(267) 아래로 시트가 19만큼 겹친다.
        SizedBox(
          height: 267,
          width: double.infinity,
          child: ClipRect(
            child: GestureDetector(
              onLongPress: _status == MapLoadStatus.ready ? _toggleError : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: switch (_status) {
                  MapLoadStatus.ready => _SmallMap(
                    key: const ValueKey('map'),
                    plan: plan,
                    showRoute: _hasPlan,
                    selectedId: _selectedId ?? plan.currentId,
                    onTapPin: _select,
                    onExpand: _openFullMap,
                  ),
                  MapLoadStatus.loading => const ColoredBox(
                    key: ValueKey('loading'),
                    color: mapGround,
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.brand),
                      ),
                    ),
                  ),
                  MapLoadStatus.error => _MapError(key: const ValueKey('error'), onRetry: _reload),
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 248),
          child: _ScheduleSheet(
            day: widget.day,
            plan: _hasPlan ? plan : null,
            onTapStop: _select,
            onAdd: _openAddSchedule,
          ),
        ),
      ],
    );
  }
}

// ── 지도 ──────────────────────────────────────────────────────────────

class _SmallMap extends StatelessWidget {
  const _SmallMap({
    super.key,
    required this.plan,
    required this.showRoute,
    required this.selectedId,
    required this.onTapPin,
    required this.onExpand,
  });

  final MapDay plan;
  final bool showRoute;
  final String selectedId;
  final ValueChanged<MapStop> onTapPin;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: mapGround,
      child: Stack(
        children: [
          // 피그마 지도는 390 기준. 넓은 화면에서는 가운데에 둔다.
          Positioned.fill(
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Center(
                child: MapCanvas(
                  asset: 'assets/icons/map_base_small.svg',
                  size: const Size(390, 267),
                  pins: smallMapPins,
                  route: plan.route,
                  day: plan,
                  showRoute: showRoute,
                  selectedId: selectedId,
                  onTapPin: onTapPin,
                ),
              ),
            ),
          ),
          Positioned(
            right: 9,
            top: 10,
            child: MapRoundButton(
              label: '지도 크게 보기',
              size: 40,
              onTap: onExpand,
              child: const AxisIcon(KitIcon.navExpand),
            ),
          ),
        ],
      ),
    );
  }
}

/// 07_09 지도 · 오류: 지도 자리에 빈 상태 + "다시 시도".
class _MapError extends StatelessWidget {
  const _MapError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: AxisEmptyState(
            icon: KitIcon.stateAlert,
            title: '지도를 불러오지 못했어요',
            description: '네트워크 연결을 확인하고 다시 시도해 주세요.',
            actionLabel: '다시 시도',
            onAction: onRetry,
          ),
        ),
      ),
    );
  }
}

// ── 일정 시트 ────────────────────────────────────────────────────────────

class _ScheduleSheet extends StatelessWidget {
  const _ScheduleSheet({required this.day, required this.plan, required this.onTapStop, required this.onAdd});

  final int day;
  final MapDay? plan;
  final ValueChanged<MapStop> onTapStop;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayNames[_dayNumbers.indexOf(day).clamp(0, 6)];
    final plan = this.plan;
    final count = plan?.numbered.length ?? 0;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFD0D4DB), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('11월 $day일 $weekday', style: AxisText.title18.copyWith(color: AppColors.gray07, height: 1.3)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('일정 $count개', style: AxisText.body.copyWith(color: AppColors.gray06)),
                ),
                if (plan != null) const _EditButton(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: plan == null
                ? Padding(
                    key: ValueKey('empty$day'),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    // 07_05 일정 목록 · 빈 상태와 같은 + 아이콘과 "일정 추가하기" 버튼.
                    child: AxisEmptyState(
                      icon: KitIcon.navPlus,
                      title: '이 날은 아직 일정이 없어요',
                      description: '일정을 추가하면 지도에 동선이 그려져요',
                      actionLabel: '일정 추가하기',
                      onAction: onAdd,
                    ),
                  )
                : _Timeline(key: ValueKey(plan.optimized), plan: plan, onTapStop: onTapStop),
          ),
          if (plan != null) ...[const SizedBox(height: 12), _AddScheduleButton(onTap: onAdd)],
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton();

  @override
  Widget build(BuildContext context) {
    void tap() => showAxisToast(context, '목록 탭에서 일정을 편집할 수 있어요.', bottom: 82);
    return PressBuilder(
      semanticLabel: '편집',
      onTap: tap,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 26, minWidth: 56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pressed ? AppColors.gray01 : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.gray02),
        ),
        child: const Text(
          '편집',
          style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.gray07),
        ),
      ),
    );
  }
}

/// 타임라인(Start · Transit · Place Row). 마커 가운데를 잇는 세로선을 줄마다 뒤에 깐다.
class _Timeline extends StatelessWidget {
  const _Timeline({super.key, required this.plan, required this.onTapStop});

  final MapDay plan;
  final ValueChanged<MapStop> onTapStop;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    final entries = plan.entries;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final Widget row = switch (e) {
        MapStop(isHome: true) => AxisTimelineStartRow(
          time: e.time!,
          title: e.title,
          place: e.listPlace,
          prepValue: '20분',
          onTap: () => onTapStop(e),
        ),
        MapStop() => AxisTimelinePlaceRow(
          time: e.time!,
          number: e.number!,
          title: e.title,
          place: e.listPlace,
          state: e.id == plan.currentId ? AxisMarkerState.current : AxisMarkerState.normal,
          onTap: () => onTapStop(e),
        ),
        MapMove() => AxisTimelineTransitRow(
          duration: '${e.minutes}분 소요\n${e.distance}',
          mode: e.mode.label,
          icon: e.mode.icon,
          route: e.route,
          detail: e.detail,
        ),
        _ => const SizedBox.shrink(),
      };
      rows.add(_LineBehind(first: i == 0, last: i == entries.length - 1, child: row));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

class _LineBehind extends StatelessWidget {
  const _LineBehind({required this.first, required this.last, required this.child});

  final bool first;
  final bool last;
  final Widget child;

  static const _line = ColoredBox(color: AppColors.disabledFill, child: SizedBox(width: 2));

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          // 시간 칸 60 + 간격 14 + 마커 반지름 12.5 - 선 반폭 1
          left: 85.5,
          top: 0,
          bottom: 0,
          child: Column(
            children: [
              Expanded(child: first ? const SizedBox(width: 2) : _line),
              Expanded(child: last ? const SizedBox(width: 2) : _line),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _AddScheduleButton extends StatelessWidget {
  const _AddScheduleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: '이날 일정 추가하기',
      onTap: onTap,
      builder: (context, pressed) => CustomPaint(
        painter: const _DashedBorderPainter(),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: pressed ? AppColors.gray01 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '+',
                style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.body),
              ),
              SizedBox(width: 6),
              Text(
                '이날 일정 추가하기',
                style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.body),
              ),
            ],
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

/// "동선 최적화하기" 떠 있는 알약([AxisAiPill]). 하단바 위 24에 고정.
class MapOptimizeButton extends StatelessWidget {
  const MapOptimizeButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AxisAiPill(label: '동선 최적화하기', onTap: onTap);
  }
}
