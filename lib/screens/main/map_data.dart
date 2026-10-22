import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

/// 07_09 지도 화면들이 함께 쓰는 하루 일정(11월 23일) 데이터와 작은 위젯들.

// ── 색 ────────────────────────────────────────────────────────────────
abstract final class MapColors {
  static const ground = Color(0xFFF3F2EE); // 지도 바탕
  static const cardBg = Color(0xFFF4F5FA); // gray01: 일정 카드
  static const listGray = Color(0xFF919191);
  static const kmGray = Color(0xFFC4C4C4);
  static const textStrong = Color(0xFF1F2027);
  static const textDark = Color(0xFF191F28);
  static const textSub = Color(0xFF8B95A1);
  static const textBody = Color(0xFF4E5968);
  static const textMid = Color(0xFF636B78);
  static const muted = Color(0xFFB0B8C1);
  static const handle = Color(0xFFD0D4DB);
  static const pinRed = Color(0xFFE5484D); // 지도 핀의 빨강(목록 배지는 cube_color06)
}

// ── 데이터 ─────────────────────────────────────────────────────────────
enum MoveMode { subway, bus, walk }

extension MoveModeX on MoveMode {
  String get label => const ['지하철', '버스', '도보'][index];
  String? get icon => switch (this) {
    MoveMode.subway => 'assets/icons/map_subway.svg',
    MoveMode.bus => 'assets/icons/map_bus.svg',
    MoveMode.walk => null,
  };
}

/// 하루 동선 위의 한 장소(집 또는 번호 붙은 일정).
class MapStop {
  const MapStop({
    required this.id,
    required this.title,
    required this.place,
    required this.address,
    this.number,
    this.color = AppColors.primary,
    this.pinColor,
    this.time,
    this.listSub,
    this.moveText,
    this.moveDetail,
    this.moveMode,
    this.cardMove,
    this.prepNote,
  });

  final String id;
  final String title; // 일정 이름(집이면 '집')
  final String place; // 장소 이름
  final String address; // 짧은 주소
  final int? number; // 일정 번호(집이면 null)
  final Color color; // 목록 배지 색
  final Color? pinColor; // 지도 핀 색(없으면 color)
  final String? time; // 'AM 08:30'
  final String? listSub; // 목록 두 번째 줄
  final String? moveText; // 상세 시트: '지하철 15분'
  final String? moveDetail; // 상세 시트: '3.5km · 광흥창역 → 공덕역'
  final MoveMode? moveMode;
  final String? cardMove; // 크게 보기 카드: '집에서 지하철 15분 · 3.5km'
  final String? prepNote; // '준비 20분 포함'

  bool get isHome => number == null;
  Color get mapColor => pinColor ?? color;

  MapStop copyWith({String? time}) => MapStop(
    id: id,
    title: title,
    place: place,
    address: address,
    number: number,
    color: color,
    pinColor: pinColor,
    time: time ?? this.time,
    listSub: listSub,
    moveText: moveText,
    moveDetail: moveDetail,
    moveMode: moveMode,
    cardMove: cardMove,
    prepNote: prepNote,
  );
}

/// 두 장소 사이 이동 줄.
class MapMove {
  const MapMove(this.mode, this.minutes, this.distance, this.route);

  final MoveMode mode;
  final int minutes;
  final String distance;
  final String route;
}

const homeStop = MapStop(id: 'home', title: '집', place: '집', address: '서울 마포구 신수동', listSub: '서울특별시ㆍ마포구 신수동');

const _work = MapStop(
  id: 's1',
  number: 1,
  color: CubeColors.green,
  time: 'AM 08:30',
  title: '회사 출근',
  place: '브릿지파트너스',
  address: '서울 마포구 공덕동',
  listSub: '브릿지파트너스',
  moveMode: MoveMode.subway,
  moveText: '지하철 15분',
  moveDetail: '3.5km · 광흥창역 → 공덕역',
  cardMove: '집에서 지하철 15분 · 3.5km',
  prepNote: '준비 20분 포함',
);

const _submit = MapStop(
  id: 's2',
  number: 2,
  color: CubeColors.green,
  time: 'AM 11:00',
  title: '기획안 제출',
  place: '브릿지파트너스',
  address: '서울 마포구 공덕동',
  listSub: '브릿지파트너스',
  moveMode: MoveMode.walk,
  moveText: '이동 없음',
  moveDetail: '같은 건물',
  cardMove: '같은 건물 · 이동 없음',
);

const _lunch = MapStop(
  id: 's3',
  number: 3,
  color: CubeColors.green,
  time: 'PM 12:30',
  title: '팀 점심',
  place: '경의선숲길',
  address: '서울 마포구 공덕동',
  listSub: '서울특별시ㆍ공덕동 경의선숲길',
  moveMode: MoveMode.walk,
  moveText: '도보 5분',
  moveDetail: '400m · 회사 → 경의선숲길',
  cardMove: '회사에서 도보 5분 · 400m',
);

const _meeting = MapStop(
  id: 's4',
  number: 4,
  color: CubeColors.red,
  pinColor: MapColors.pinRed,
  time: 'PM 03:00',
  title: '고객사 미팅',
  place: '토스증권',
  address: '서울 영등포구 여의도동',
  listSub: '토스증권',
  moveMode: MoveMode.subway,
  moveText: '지하철 15분',
  moveDetail: '3.5km · 공덕역 → 여의나루역',
  cardMove: '점심 장소에서 지하철 15분 · 3.5km',
);

const _running = MapStop(
  id: 's5',
  number: 5,
  color: CubeColors.orange,
  time: 'PM 07:30',
  title: '러닝',
  place: '여의도 한강공원',
  address: '서울 영등포구 여의도동',
  listSub: '여의도 한강공원',
  moveMode: MoveMode.bus,
  moveText: '버스 10분',
  moveDetail: '3.5km · 광흥창역 → 여의나루역',
  cardMove: '집에서 버스 10분 · 3.5km',
);

const _bill = MapStop(
  id: 's6',
  number: 6,
  color: CubeColors.blue,
  time: 'PM 09:00',
  title: '관리비 납부',
  place: '집',
  address: '서울 마포구 신수동',
  moveMode: MoveMode.walk,
  moveText: '이동 없음',
  moveDetail: '집에서 처리',
  cardMove: '집 · 이동 없음',
);

/// 하루 일정. [optimized]면 AI 제안대로 러닝을 미팅 직후로 옮긴 순서.
class MapDay {
  const MapDay({required this.entries, required this.summary});

  /// [MapStop] 또는 [MapMove]가 순서대로 들어 있다.
  final List<Object> entries;
  final String summary;

  List<MapStop> get stops => entries.whereType<MapStop>().toList();

  /// 번호 붙은 일정(1~6), 번호 순.
  List<MapStop> get numbered => stops.where((s) => !s.isHome).toList()..sort((a, b) => a.number!.compareTo(b.number!));

  MapStop? byId(String id) {
    for (final s in stops) {
      if (s.id == id) return s;
    }
    return null;
  }

  static MapDay of({required bool optimized}) {
    if (!optimized) {
      return const MapDay(
        summary: '약 1시간 · 17.5km',
        entries: [
          homeStop,
          MapMove(MoveMode.subway, 15, '3.5km', '광흥창역 → 공덕역'),
          _work,
          _submit,
          _lunch,
          MapMove(MoveMode.subway, 15, '3.5km', '공덕역 → 여의나루역'),
          _meeting,
          MapMove(MoveMode.bus, 10, '3.5km', '여의나루역 → 광흥창역'),
          homeStop,
          MapMove(MoveMode.bus, 10, '3.5km', '광흥창역 → 여의나루역'),
          _running,
          MapMove(MoveMode.bus, 10, '3.5km', '여의나루역 → 광흥창역'),
          homeStop,
          _bill,
        ],
      );
    }
    return MapDay(
      summary: '약 45분 · 10.9km',
      entries: [
        homeStop,
        const MapMove(MoveMode.subway, 15, '3.5km', '광흥창역 → 공덕역'),
        _work,
        _submit,
        _lunch,
        const MapMove(MoveMode.subway, 15, '3.5km', '공덕역 → 여의나루역'),
        _meeting,
        const MapMove(MoveMode.walk, 5, '400m', '토스증권 → 한강공원'),
        _running.copyWith(time: 'PM 04:30'),
        const MapMove(MoveMode.bus, 10, '3.5km', '여의나루역 → 광흥창역'),
        homeStop,
        _bill,
      ],
    );
  }
}

// ── 지도 위 표시 ─────────────────────────────────────────────────────────

/// 번호 핀(동그라미 + 흰 테두리 + 숫자). [size] 20(작은 지도) 또는 24(AI 화면).
class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.stop, this.size = 20, this.onTap});

  final MapStop stop;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final big = size >= 24;
    final Widget face = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: stop.isHome ? AppColors.primary : stop.mapColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: big && !stop.isHome
              ? 2
              : (stop.number ?? 0) >= 4 || stop.isHome
              ? 1.5
              : 1,
        ),
        boxShadow: stop.isHome
            ? null
            : [
                BoxShadow(
                  color: big ? const Color(0x2E000000) : const Color(0x55000000),
                  blurRadius: big ? 3 : 4,
                  offset: big ? const Offset(0, 1) : Offset.zero,
                ),
              ],
      ),
      child: stop.isHome
          ? SvgPicture.asset('assets/icons/map_home.svg', width: big ? 9 : 9, height: 9)
          : Text(
              '${stop.number}',
              style: TextStyle(
                fontSize: 12,
                height: 1,
                fontWeight: big ? FontWeight.w700 : FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
    if (onTap == null) return face;
    return Semantics(
      button: true,
      label: stop.isHome ? '집 핀' : '${stop.number}번 ${stop.title} 핀',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // 탭 영역을 핀보다 조금 넓힌다.
        child: Padding(padding: const EdgeInsets.all(6), child: face),
      ),
    );
  }
}

/// 선택된 핀 둘레의 파란 고리(살짝 숨 쉬듯 커졌다 작아진다).
class MapPinRing extends StatefulWidget {
  const MapPinRing({super.key, required this.size});

  final double size;

  @override
  State<MapPinRing> createState() => _MapPinRingState();
}

class _MapPinRingState extends State<MapPinRing> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ScaleTransition(
        scale: Tween(begin: 0.92, end: 1.06).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

/// 지도 위 핀 배치. [pins]는 장소 id → 핀 왼쪽 위 좌표.
class MapPinLayer extends StatelessWidget {
  const MapPinLayer({
    super.key,
    required this.day,
    required this.pins,
    required this.selectedId,
    required this.onTapPin,
    this.pinSize = 20,
    this.ringSize = 32,
  });

  final MapDay day;
  final Map<String, Offset> pins;
  final String? selectedId;
  final ValueChanged<MapStop> onTapPin;
  final double pinSize;
  final double ringSize;

  static const _hit = 6.0;

  @override
  Widget build(BuildContext context) {
    // 피그마 순서: 2 → 1 → 3 → 4 → 5 → 집 (1이 2 위에 겹친다)
    const order = ['s2', 's1', 's3', 's4', 's5', 'home'];
    final children = <Widget>[];
    final sel = selectedId == null ? null : pins[selectedId == 's6' ? 'home' : selectedId];
    if (sel != null) {
      final c = sel + Offset(pinSize / 2, pinSize / 2);
      children.add(
        Positioned(
          key: const ValueKey('ring'),
          left: c.dx - ringSize / 2,
          top: c.dy - ringSize / 2,
          child: MapPinRing(size: ringSize),
        ),
      );
    }
    for (final id in order) {
      final pos = pins[id];
      final stop = id == 'home' ? homeStop : day.byId(id);
      if (pos == null || stop == null) continue;
      children.add(
        Positioned(
          left: pos.dx - _hit,
          top: pos.dy - _hit,
          child: MapPin(stop: stop, size: pinSize, onTap: () => onTapPin(stop)),
        ),
      );
    }
    return Stack(clipBehavior: Clip.none, children: children);
  }
}

/// 목록·카드의 작은 번호 배지(둥근 사각형). 집이면 흰 집 모양.
class MapBadge extends StatelessWidget {
  const MapBadge({super.key, required this.stop, this.size = 18, this.fontSize = 14, this.bold = false});

  final MapStop stop;
  final double size;
  final double fontSize;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: stop.color, borderRadius: BorderRadius.circular(4)),
      child: stop.isHome
          ? SvgPicture.asset('assets/icons/map_home.svg', width: 9, height: 9)
          : Text(
              '${stop.number}',
              style: TextStyle(
                fontSize: fontSize,
                height: 1,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
    );
  }
}

/// 흰 동그라미 떠 있는 버튼(뒤로·접기·내 위치).
class MapRoundButton extends StatelessWidget {
  const MapRoundButton({super.key, required this.label, required this.onTap, required this.child, this.size = 44});

  final String label;
  final VoidCallback onTap;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: label,
        child: Pressable(
          onTap: onTap,
          scale: 0.92,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x29000000), blurRadius: 14, offset: Offset(0, 4))],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── 07_09-2 장소 상세 시트 ───────────────────────────────────────────────

Future<void> showPlaceDetailSheet(BuildContext context, MapStop stop) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x33000000),
    builder: (_) => PlaceDetailSheet(stop: stop),
  );
}

class PlaceDetailSheet extends StatelessWidget {
  const PlaceDetailSheet({super.key, required this.stop});

  final MapStop stop;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final purpose = stop.isHome ? '출발·도착 장소' : '${stop.title} 장소';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottom > 0 ? bottom : 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: MapColors.handle, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  stop.place,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: MapColors.textStrong),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 32,
                height: 32,
                child: OverflowBox(
                  maxWidth: 44,
                  maxHeight: 44,
                  child: IconButton(
                    tooltip: '닫기',
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: SvgPicture.asset('assets/icons/map_close.svg', width: 32, height: 32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('${stop.address} · $purpose', style: const TextStyle(fontSize: 14, color: MapColors.textSub)),
          const SizedBox(height: 16),
          _InfoRow(
            icon: SvgPicture.asset('assets/icons/map_clock.svg', width: 18, height: 18),
            main: stop.time == null ? '오늘 출발·도착' : '${stop.time} 도착',
            sub: stop.prepNote ?? (stop.isHome ? '준비 20분' : '정시 도착 예정'),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: stop.moveMode?.icon == null
                ? const Icon(Icons.directions_walk_rounded, size: 18, color: MapColors.textSub)
                : SvgPicture.asset(
                    stop.moveMode!.icon!,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(MapColors.textSub, BlendMode.srcIn),
                  ),
            main: stop.moveText ?? '이동 없음',
            sub: stop.moveDetail ?? '하루의 시작과 끝',
          ),
          const SizedBox(height: 16),
          BrandButton(
            label: '길찾기',
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('${stop.place}까지 길찾기를 시작해요.')));
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.main, required this.sub});

  final Widget icon;
  final String main;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 18, height: 18, child: icon),
        const SizedBox(width: 10),
        Text(
          main,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: MapColors.textStrong),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            sub,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: MapColors.textSub),
          ),
        ),
      ],
    );
  }
}

/// AI 오브(파랗게 빛나는 구슬 + 흰 십자). 피그마 래스터 대신 그라디언트로 그린다.
class AiOrb extends StatelessWidget {
  const AiOrb({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final bar = size * 0.36;
    final thick = size * 0.11;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.25, -0.35),
          radius: 0.85,
          colors: [Color(0xFFF4F9FF), Color(0xFFB9DAFF), Color(0xFF5FA2FF), Color(0xFF1F6BFF)],
          stops: [0.0, 0.35, 0.72, 1.0],
        ),
        boxShadow: [BoxShadow(color: Color(0x553D8BFF), blurRadius: 6)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: bar,
            height: thick,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(thick)),
          ),
          Container(
            width: thick,
            height: bar,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(thick)),
          ),
        ],
      ),
    );
  }
}
