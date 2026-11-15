import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import '../../widgets/status_bar_blur.dart';
import 'event_affirmation_screen.dart';
import 'event_attendance_screen.dart';
import 'event_badge_collection_screen.dart';
import 'event_cube_screen.dart';
import 'event_data.dart';
import 'event_invite_screen.dart';
import 'event_plan_king_screen.dart';

/// 이벤트 종류에 맞는 상세 화면(10-1~10-6).
Widget eventDetailScreen(EventKind kind) => switch (kind) {
  EventKind.cube => const EventCubeScreen(),
  EventKind.attendance => const EventAttendanceScreen(),
  EventKind.planKing => const EventPlanKingScreen(),
  EventKind.affirmation => const EventAffirmationScreen(),
  EventKind.invite => const EventInviteScreen(),
  EventKind.badgeCollection => const EventBadgeCollectionScreen(),
};

/// 배너 순서: 큐브 자랑이 맨 앞, 나머지는 목록 순서.
const _bannerOrder = [EventKind.cube, ...eventListOrder];

/// 10_이벤트(130:12688): 이벤트 탭 첫 화면.
/// 위는 09_커뮤니티처럼 큐브 한 층을 돌리듯 넘어가는 배너(1/6), 아래는 "혜택 가득! 진행 중인 이벤트" 목록. 배너·줄을 누르면 상세로 간다.
class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  /// 배너는 09_커뮤니티 후기 카드처럼 큐브 한 층을 돌리듯 넘어간다(옆면은 어두워진다).
  final _cube = AxisCubeCarouselController();
  int _index = 0;

  void _open(EventKind kind) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => eventDetailScreen(kind)));
  }

  void _goTo(int page) {
    if (page > _index + 1) _cube.next();
    if (page < _index + 1) _cube.previous();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const AxisTabBar(current: MainTab.event),
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              children: [
                const SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      '이벤트',
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.3,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray06,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: AxisCubeCarousel(
                    controller: _cube,
                    size: const Size(350, 282),
                    faceCount: _bannerOrder.length,
                    onChanged: (i) => setState(() => _index = i),
                    faceBuilder: (context, i, dim) =>
                        _Banner(info: eventCatalog[_bannerOrder[i]]!, dim: dim, onTap: () => _open(_bannerOrder[i])),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: AxisPager(page: _index + 1, count: _bannerOrder.length, onChanged: _goTo),
                ),
                const SizedBox(height: 16),
                const AxisSectionDivider(),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(
                          text: '혜택 가득!',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(text: ' 진행 중인 이벤트'),
                      ],
                    ),
                    style: AxisText.sectionTitle.copyWith(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: EventStatusStore.statuses,
                  builder: (context, statuses, _) => Column(
                    children: [
                      for (final kind in eventListOrder)
                        _EventRow(
                          info: eventCatalog[kind]!,
                          status: statuses[kind]!,
                          last: kind == eventListOrder.last,
                          onTap: () => _open(kind),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            const StatusBarBlur(tint: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// 350×282 배너 한 면: 하늘빛 방사형 바탕 + 큰 제목(검정→파랑 그라디언트) + 설명 + 그림.
/// Banner/Event(205:10599): 350×282, 굴곡 8, 흰 그림자(흐림 10, 퍼짐 5).
/// 바탕은 #F4F5FA 위 오른쪽 위(350, 64)를 중심으로 한 타원(가로 350·세로 224) 방사 그라디언트(#71C3FF 14·18% → #E0F2FF).
/// 오른쪽 위 3D 그림, 왼쪽 40에서 위 99 큰 제목(26 ExtraBold, 검정 → #0057ED 가로 그라디언트),
/// 위 208 설명(12, gray06).
class _Banner extends StatelessWidget {
  const _Banner({required this.info, required this.dim, required this.onTap});

  final EventInfo info;

  /// 옆으로 돌아간 만큼 덮는 검정의 불투명도(0~0.35).
  final double dim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final art = eventBannerArt[info.kind]!;
    return Semantics(
      button: true,
      label: info.bannerTitle.replaceAll(RegExp(r'\s+'), ' '),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 350,
          height: 282,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5FA),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 5)],
            gradient: const RadialGradient(
              center: Alignment(1, -0.546),
              radius: 350 / 282,
              colors: [Color(0xFF71C3FF), Color(0xFF71C3FF), Color(0xFFE0F2FF)],
              stops: [0.14, 0.18, 1],
              transform: _ScaleYAround(0.64, Alignment(1, -0.546)),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: art.left,
                top: art.top,
                width: art.width,
                child: Image.asset(art.asset, fit: BoxFit.contain),
              ),
              // 글자 그라디언트(검정 → #0057ED)는 글 상자 폭에 걸리므로 폭을 글에 맞춘다.
              Positioned(
                left: 40,
                top: 99,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) =>
                      const LinearGradient(colors: [Colors.black, Color(0xFF0057ED)]).createShader(r),
                  child: Text(
                    info.bannerTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      height: 1.19,
                      letterSpacing: -0.52,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(left: 40, top: 208, right: 20, child: Text(info.bannerCaption, style: AxisText.caption)),
              if (dim > 0)
                Positioned.fill(
                  child: ColoredBox(color: Colors.black.withValues(alpha: dim)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 방사 그라디언트를 [center] 기준으로 세로만 [scale]배(피그마 타원).
class _ScaleYAround extends GradientTransform {
  const _ScaleYAround(this.scale, this.center);

  final double scale;
  final Alignment center;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final c = center.withinRect(bounds);
    return Matrix4.translationValues(c.dx, c.dy, 0)
      ..scaleByDouble(1, scale, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
  }
}

/// 목록 줄: 40px 이벤트 아이콘 + 제목(16 SemiBold) · 남은 날(12 gray06) + 참여 상태. 아래 1px 선.
class _EventRow extends StatelessWidget {
  const _EventRow({required this.info, required this.status, required this.last, required this.onTap});

  final EventInfo info;
  final AxisEventStatus status;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: info.listTitle,
      onTap: onTap,
      scale: 1,
      builder: (context, pressed) => Container(
        color: pressed ? AppColors.gray01 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: last ? null : const Border(bottom: BorderSide(color: AppColors.gray02)),
          ),
          child: Row(
            children: [
              // Icon/Event(130:10220) 그대로 40×40. 이미지가 이미 컴포넌트 40 칸 기준으로 잘려 있다.
              AxisEventIcon(info.icon!),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.listTitle, style: AxisText.rowTitle.copyWith(color: Colors.black)),
                    const SizedBox(height: 2),
                    Text(info.daysLeftLabel, style: AxisText.caption),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AxisEventStatusBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }
}
