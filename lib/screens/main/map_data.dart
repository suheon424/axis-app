import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';

/// 07_09 지도 화면들이 함께 쓰는 하루 일정(11월 23일) 데이터와 지도 위젯들.

/// 지도 바탕색(피그마 Map 벡터 #F3F4F9).
const mapGround = Color(0xFFF3F4F9);

// ── 데이터 ─────────────────────────────────────────────────────────────
enum MoveMode { subway, bus, walk }

extension MoveModeX on MoveMode {
  String get label => const ['지하철', '버스', '도보'][index];
  String get icon => const [KitIcon.subway, KitIcon.busFilled, KitIcon.walk][index];
}

/// 하루 동선 위의 한 장소(집 또는 번호 붙은 일정).
class MapStop {
  const MapStop({
    required this.id,
    required this.title,
    required this.place,
    required this.address,
    this.number,
    this.time,
    this.listPlace,
    this.moveMode,
    this.moveText,
    this.moveDetail,
    this.cardMove,
    this.prepNote,
  });

  final String id;

  /// 일정 이름(집이면 '집').
  final String title;

  /// 장소 이름(상세 카드 제목).
  final String place;
  final String address;

  /// 일정 번호(집이면 null).
  final int? number;

  /// 예: '08:30 AM'
  final String? time;

  /// 타임라인 제목 오른쪽 회색 글.
  final String? listPlace;
  final MoveMode? moveMode;

  /// 상세 카드: '지하철 15분'
  final String? moveText;

  /// 상세 카드: '3.5km · 광흥창역 → 공덕역'
  final String? moveDetail;

  /// 크게 보기 카드: '집에서 지하철 15분 · 3.5km'
  final String? cardMove;

  /// '준비 20분 포함'
  final String? prepNote;

  bool get isHome => number == null;

  MapStop copyWith({String? time, String? cardMove, String? moveText, String? moveDetail, MoveMode? moveMode}) =>
      MapStop(
        id: id,
        title: title,
        place: place,
        address: address,
        number: number,
        time: time ?? this.time,
        listPlace: listPlace,
        moveMode: moveMode ?? this.moveMode,
        moveText: moveText ?? this.moveText,
        moveDetail: moveDetail ?? this.moveDetail,
        cardMove: cardMove ?? this.cardMove,
        prepNote: prepNote,
      );
}

/// 두 장소 사이 이동 줄.
class MapMove {
  const MapMove(this.mode, this.minutes, this.distance, this.route, [this.detail]);

  final MoveMode mode;
  final int minutes;
  final String distance;
  final String route;

  /// 아래 줄(예: '2호선 공덕 방면', '7730, 7719').
  final String? detail;
}

const homeStop = MapStop(
  id: 'home',
  title: '집',
  place: '집',
  address: '서울 마포구 신수동',
  time: '07:55 AM',
  listPlace: '서울 · 마포구',
  prepNote: '준비 20분',
);

const _work = MapStop(
  id: 's1',
  number: 1,
  time: '08:30 AM',
  title: '회사 출근',
  place: '브릿지파트너스',
  address: '서울 마포구 공덕동',
  listPlace: '브릿지파트너스',
  moveMode: MoveMode.subway,
  moveText: '지하철 15분',
  moveDetail: '3.5km · 광흥창역 → 공덕역',
  cardMove: '집에서 지하철 15분 · 3.5km',
  prepNote: '준비 20분 포함',
);

const _submit = MapStop(
  id: 's2',
  number: 2,
  time: '11:00 AM',
  title: '기획안 제출',
  place: '브릿지파트너스',
  address: '서울 마포구 공덕동',
  listPlace: '브릿지파트너스',
  moveMode: MoveMode.walk,
  moveText: '이동 없음',
  moveDetail: '같은 건물',
  cardMove: '같은 건물 · 이동 없음',
);

const _lunch = MapStop(
  id: 's3',
  number: 3,
  time: '12:30 PM',
  title: '팀 점심',
  place: '경의선숲길',
  address: '서울 마포구 공덕동',
  listPlace: '경의선숲길',
  moveMode: MoveMode.walk,
  moveText: '도보 5분',
  moveDetail: '400m · 회사 → 경의선숲길',
  cardMove: '회사에서 도보 5분 · 400m',
);

const _meeting = MapStop(
  id: 's4',
  number: 4,
  time: '03:00 PM',
  title: '고객사 미팅',
  place: '토스증권',
  address: '서울 영등포구 여의도동',
  listPlace: '토스증권',
  moveMode: MoveMode.subway,
  moveText: '지하철 15분',
  moveDetail: '3.5km · 공덕역 → 여의나루역',
  cardMove: '점심 장소에서 지하철 15분 · 3.5km',
);

const _running = MapStop(
  id: 's5',
  number: 5,
  time: '07:30 PM',
  title: '러닝',
  place: '여의도 한강공원',
  address: '서울 영등포구 여의도동',
  listPlace: '여의도 한강공원',
  moveMode: MoveMode.bus,
  moveText: '버스 10분',
  moveDetail: '3.5km · 광흥창역 → 여의나루역',
  cardMove: '집에서 버스 10분 · 3.5km',
);

const _bill = MapStop(
  id: 's6',
  number: 6,
  time: '09:30 PM',
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
  const MapDay({required this.entries, required this.route, required this.optimized});

  /// [MapStop] 또는 [MapMove]가 순서대로 들어 있다.
  final List<Object> entries;

  /// 지도에 그리는 동선(핀 id 순서).
  final List<String> route;
  final bool optimized;

  List<MapStop> get stops => entries.whereType<MapStop>().toList();

  /// 번호 붙은 일정(1~6), 번호 순.
  List<MapStop> get numbered => stops.where((s) => !s.isHome).toList()..sort((a, b) => a.number!.compareTo(b.number!));

  /// 지금 진행 중인 일정(타임라인 파란 표시).
  String get currentId => 's3';

  MapStop? byId(String id) {
    for (final s in stops) {
      if (s.id == id) return s;
    }
    return null;
  }

  static MapDay of({required bool optimized}) {
    if (!optimized) {
      return const MapDay(
        optimized: false,
        route: ['home', 's1', 's3', 's4', 's5'],
        entries: [
          homeStop,
          MapMove(MoveMode.subway, 15, '3.5km', '광흥창역 → 공덕역', '2호선 공덕 방면'),
          _work,
          _submit,
          _lunch,
          MapMove(MoveMode.subway, 15, '3.5km', '공덕역 → 여의나루역', '공덕 방면'),
          _meeting,
          MapMove(MoveMode.subway, 15, '3.5km', '여의나루역 → 광흥창역', '공덕 방면'),
          MapMove(MoveMode.bus, 10, '3.5km', '광흥창역 → 여의나루역', '7730, 7719'),
          _running,
          _bill,
        ],
      );
    }
    return MapDay(
      optimized: true,
      route: const ['home', 's1', 's3', 's4', 's5', 'home'],
      entries: [
        homeStop,
        const MapMove(MoveMode.subway, 15, '3.5km', '광흥창역 → 공덕역', '2호선 공덕 방면'),
        _work,
        _submit,
        _lunch,
        const MapMove(MoveMode.subway, 15, '3.5km', '공덕역 → 여의나루역', '공덕 방면'),
        _meeting,
        const MapMove(MoveMode.walk, 5, '400m', '토스증권 → 한강공원'),
        _running.copyWith(
          time: '04:30 PM',
          moveMode: MoveMode.walk,
          moveText: '도보 5분',
          moveDetail: '400m · 토스증권 → 한강공원',
          cardMove: '미팅 장소에서 도보 5분 · 400m',
        ),
        const MapMove(MoveMode.bus, 10, '3.5km', '여의나루역 → 광흥창역', '7730, 7719'),
        _bill,
      ],
    );
  }
}

// ── 지도 위 표시 ─────────────────────────────────────────────────────────

/// 피그마 좌표계(지도 그림 크기) 위 핀 가운데 좌표.
typedef PinMap = Map<String, Offset>;

/// 작은 지도(390×267) 핀 가운데.
const smallMapPins = <String, Offset>{
  'home': Offset(128.9, 29.5),
  's1': Offset(264.8, 52.6),
  's2': Offset(252.8, 45.6),
  's3': Offset(230.3, 40.6),
  's4': Offset(132.5, 225.6),
  's5': Offset(158.3, 196),
};

/// 크게 보기·AI 제안 지도(390×844) 핀 가운데.
const bigMapPins = <String, Offset>{
  'home': Offset(75.3, 195.3),
  's1': Offset(322.6, 237.3),
  's2': Offset(309, 229),
  's3': Offset(259.7, 215.5),
  's4': Offset(82, 551.8),
  's5': Offset(128.8, 498),
};

/// AI 분석 중 지도(390×844) 핀 가운데.
const aiMapPins = <String, Offset>{
  'home': Offset(117, 113),
  's1': Offset(271, 140),
  's2': Offset(258, 132),
  's3': Offset(230, 126),
  's4': Offset(116, 343),
  's5': Offset(146, 308),
};

/// Pin/집: 흰 원 + 검정 테두리 + 집 모양.
class MapHomePin extends StatelessWidget {
  const MapHomePin({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gray07),
      ),
      child: AxisIcon(KitIcon.homeGlyph, size: size * 0.42, color: AppColors.gray07),
    );
  }
}

/// 지도 그림 + 동선 + 핀. [size]는 피그마 지도 크기, 핀 좌표도 같은 좌표계.
class MapCanvas extends StatelessWidget {
  const MapCanvas({
    super.key,
    required this.asset,
    required this.size,
    required this.pins,
    required this.route,
    this.day,
    this.removed = const [],
    this.selectedId,
    this.highlightId,
    this.onTapPin,
    this.routeWidth = 3,
    this.showRoute = true,
  });

  final String asset;
  final Size size;
  final PinMap pins;
  final List<String> route;

  /// 회색 점선으로 그릴 빠지는 구간.
  final List<String> removed;
  final MapDay? day;

  /// 파랗게 빛나는 핀.
  final String? selectedId;

  /// 파란 핀(선택과 별개로 바뀐 일정 강조).
  final String? highlightId;
  final ValueChanged<MapStop>? onTapPin;
  final double routeWidth;
  final bool showRoute;

  static const _hit = 8.0;

  @override
  Widget build(BuildContext context) {
    final day = this.day ?? MapDay.of(optimized: false);
    // 피그마 순서: 2 → 1 → 3 → 4 → 5 → 집 (1이 2 위에 겹친다). 선택 핀은 맨 위.
    final order = ['s2', 's1', 's3', 's4', 's5', 'home'];
    final sel = selectedId == 's6' ? 'home' : selectedId;
    if (sel != null && order.remove(sel)) order.add(sel);
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: SvgPicture.asset(asset, fit: BoxFit.fill)),
          if (showRoute)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _RoutePainter(
                    points: [for (final id in route) ?pins[id]],
                    removed: [for (final id in removed) ?pins[id]],
                    width: routeWidth,
                  ),
                ),
              ),
            ),
          if (showRoute)
            for (final id in order)
              if (pins[id] != null && (id == 'home' || day.byId(id) != null))
                Positioned(
                  key: ValueKey('pin-$id'),
                  left: pins[id]!.dx - 10 - _hit,
                  top: pins[id]!.dy - 10 - _hit,
                  child: _TapPin(
                    stop: id == 'home' ? homeStop : day.byId(id)!,
                    blue: id == sel || id == highlightId,
                    onTap: onTapPin,
                  ),
                ),
        ],
      ),
    );
  }
}

class _TapPin extends StatelessWidget {
  const _TapPin({required this.stop, required this.blue, required this.onTap});

  final MapStop stop;
  final bool blue;
  final ValueChanged<MapStop>? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget face = stop.isHome
        ? const MapHomePin()
        : SizedBox(width: 20, height: 20, child: AxisNumberBadge(stop.number!, blue: blue));
    return Semantics(
      button: onTap != null,
      label: stop.isHome ? '집 핀' : '${stop.number}번 ${stop.title} 핀',
      excludeSemantics: true,
      onTap: onTap == null ? null : () => onTap!(stop),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(stop),
        child: Padding(padding: const EdgeInsets.all(MapCanvas._hit), child: face),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.points, required this.removed, required this.width});

  final List<Offset> points;
  final List<Offset> removed;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (removed.length > 1) {
      final dash = Paint()
        ..color = AppColors.gray05
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < removed.length - 1; i++) {
        final a = removed[i], b = removed[i + 1];
        final len = (b - a).distance;
        final dir = (b - a) / len;
        for (var d = 0.0; d < len; d += 9) {
          canvas.drawLine(a + dir * d, a + dir * (d + 5).clamp(0, len), dash);
        }
      }
    }
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.brand
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.points != points || old.removed != removed;
}

/// 흰 동그라미 떠 있는 버튼(접기·펴기).
class MapRoundButton extends StatelessWidget {
  const MapRoundButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.size = 44,
    this.color = Colors.white,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Color(0x29000000), blurRadius: 14, offset: Offset(0, 4))],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Place Card 1_선택시(130:11195): 장소 상세 시트 ─────────────────────────

Future<void> showPlaceDetailSheet(BuildContext context, MapStop stop) {
  return showAxisSheet<void>(
    context,
    title: stop.place,
    builder: (_) => PlaceDetailSheet(stop: stop),
    footer: (ctx) => AxisCtaButton(
      label: '길찾기',
      onPressed: () {
        Navigator.of(ctx).pop();
        showAxisToast(context, '${stop.place}까지 길찾기를 시작해요.');
      },
    ),
  );
}

/// 장소 상세 시트 본문: 주소·용도, 도착 시간, 이동 수단.
class PlaceDetailSheet extends StatelessWidget {
  const PlaceDetailSheet({super.key, required this.stop});

  final MapStop stop;

  @override
  Widget build(BuildContext context) {
    final purpose = stop.isHome ? '출발·도착 장소' : '${stop.title} 장소';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0, -10),
          child: Text('${stop.address} · $purpose', style: AxisText.caption.copyWith(fontSize: 13)),
        ),
        const SizedBox(height: 6),
        _InfoRow(
          icon: KitIcon.clock,
          main: stop.isHome ? '${stop.time} 출발' : '${stop.time} 도착',
          sub: stop.prepNote ?? '정시 도착 예정',
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: (stop.moveMode ?? MoveMode.walk).icon,
          main: stop.moveText ?? '이동 없음',
          sub: stop.moveDetail ?? '하루의 시작과 끝',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.main, required this.sub});

  final String icon;
  final String main;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AxisIcon(icon, size: 20, color: AppColors.gray06),
        const SizedBox(width: 8),
        Text(main, style: AxisText.rowTitleMedium.copyWith(color: AppColors.gray07)),
        const SizedBox(width: 8),
        Expanded(child: Text(sub, maxLines: 2, style: AxisText.caption.copyWith(fontSize: 13))),
      ],
    );
  }
}

/// 버튼 속 22px AI 구슬(빛 번짐 없이 구슬만).
class MapAiGlyph extends StatelessWidget {
  const MapAiGlyph({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: OverflowBox(
          maxWidth: size * 2.5,
          maxHeight: size * 2.5,
          child: Image.asset(AxisAiOrb.asset, width: size * 2.5, height: size * 2.5),
        ),
      ),
    );
  }
}
