import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
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
/// 위는 큐브처럼 돌아가는 배너(1/6), 아래는 "혜택 가득! 진행 중인 이벤트" 목록. 배너·줄을 누르면 상세로 간다.
class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  /// 배너는 양옆으로 끝없이 돈다: 큰 페이지 번호에서 시작해 6으로 나눈 나머지를 쓴다.
  static const _start = 600;
  final _pages = PageController(viewportFraction: 292 / 390, initialPage: _start);
  int _page = _start;

  int get _index => _page % _bannerOrder.length;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _open(EventKind kind) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => eventDetailScreen(kind)));
  }

  void _goTo(int page) {
    _pages.animateToPage(page, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const AxisTabBar(current: MainTab.event),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 10),
            children: [
              const SizedBox(
                height: 40,
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
              SizedBox(
                height: 292,
                child: PageView.builder(
                  controller: _pages,
                  onPageChanged: (p) => setState(() => _page = p),
                  itemBuilder: (context, i) => _CubeFace(
                    controller: _pages,
                    index: i,
                    child: _Banner(
                      info: eventCatalog[_bannerOrder[i % _bannerOrder.length]]!,
                      onTap: () => _open(_bannerOrder[i % _bannerOrder.length]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: AxisPager(
                  page: _index + 1,
                  count: _bannerOrder.length,
                  onChanged: (p) => _goTo(_page + p - 1 - _index),
                ),
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
        ),
      ),
    );
  }
}

/// 옆 페이지를 큐브의 옆면처럼 안쪽 가장자리를 축으로 돌려 얇게 보이게 한다.
class _CubeFace extends StatelessWidget {
  const _CubeFace({required this.controller, required this.index, required this.child});

  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        var page = index.toDouble();
        if (controller.hasClients && controller.position.haveDimensions) {
          page = controller.page ?? page;
        } else {
          page = controller.initialPage.toDouble();
        }
        final d = (index - page).clamp(-1.0, 1.0);
        return Opacity(
          opacity: 1 - 0.5 * d.abs(),
          child: Transform(
            alignment: d > 0 ? Alignment.centerLeft : Alignment.centerRight,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(-d * math.pi * 0.46),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// 292×292 배너 한 면: 하늘빛 방사형 바탕 + 큰 제목(검정→파랑 그라디언트) + 설명 + 그림.
/// Banner/Event(205:10599): 292 정사각, 굴곡 8, 흰 그림자 10.
/// 바탕은 #F4F5FA 위 오른쪽 위(292, 66)를 중심으로 한 타원 방사 그라디언트(#71C3FF 14·18% → #E0F2FF).
/// 오른쪽 위 3D 그림, 왼쪽 30에서 위 109 큰 제목(26 ExtraBold, 검정 → #0057ED 가로 그라디언트),
/// 위 218 설명(12, gray06).
class _Banner extends StatelessWidget {
  const _Banner({required this.info, required this.onTap});

  final EventInfo info;
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
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F5FA),
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10)],
            gradient: RadialGradient(
              center: Alignment(1, -0.546),
              radius: 1,
              colors: [Color(0xFF71C3FF), Color(0xFF71C3FF), Color(0xFFE0F2FF)],
              stops: [0.14, 0.18, 1],
              transform: _ScaleYAround(0.795, Alignment(1, -0.546)),
            ),
          ),
          child: FittedBox(
            child: SizedBox(
              width: 292,
              height: 292,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: art.left,
                    top: art.top,
                    width: art.width,
                    child: Image.asset(art.asset, fit: BoxFit.contain),
                  ),
                  Positioned(
                    left: 30,
                    top: 109,
                    right: 20,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (r) =>
                          const LinearGradient(colors: [Colors.black, AppColors.primary]).createShader(r),
                      child: Text(
                        info.bannerTitle,
                        style: const TextStyle(
                          fontSize: 26,
                          height: 1.19,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Positioned(left: 30, top: 218, right: 20, child: Text(info.bannerCaption, style: AxisText.caption)),
                ],
              ),
            ),
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
