import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/kit/kit.dart';
import '../badge/badge_widgets.dart';
import 'event_data.dart';

/// 10-1~10-6 이벤트 상세의 공통 틀: Nav/Back Title "이벤트 상세" + 스크롤 내용 + 아래 고정 CTA.
class EventDetailScaffold extends StatelessWidget {
  const EventDetailScaffold({super.key, required this.children, required this.cta});

  final List<Widget> children;
  final Widget cta;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AxisBackTitleBar(title: '이벤트 상세'),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(padding: const EdgeInsets.only(top: 10, bottom: 30), children: children),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomCtaBar(child: cta),
      ),
    );
  }
}

/// 이벤트 그림: 3D 메탈 아이콘, 없으면 큐브.
class EventVisual extends StatelessWidget {
  const EventVisual(this.info, {super.key, this.size = 104});

  final EventInfo info;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = info.icon;
    if (icon == null) {
      return Image.asset('assets/images/event/event_cube.png', width: size, height: size, semanticLabel: '큐브');
    }
    return AxisEventIcon(icon, size: size);
  }
}

/// 상세 위 연파랑(#D3EBFF) 카드(350, 최소 높이 164, 굴곡 8).
/// 오른쪽 위 "N일 남음" + 참여 상태, 왼쪽 위 흰 꼬리표([tag]), 제목·기간, 오른쪽 그림.
class EventHero extends StatelessWidget {
  const EventHero({super.key, required this.info, required this.status, this.tag, this.tagBlue = false});

  final EventInfo info;
  final AxisEventStatus status;
  final String? tag;
  final bool tagBlue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 164),
        decoration: BoxDecoration(color: AppColors.blue01, borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 112, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.heroTitle, style: AxisText.sectionTitle.copyWith(color: AppColors.text)),
                  const SizedBox(height: 14),
                  Text(
                    info.period,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.36,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutralText,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(right: 0, top: 52, child: EventVisual(info)),
            if (tag != null) Positioned(left: 20, top: 20, child: _WhiteTag(tag!, blue: tagBlue)),
            Positioned(
              right: 12,
              top: 10,
              child: Row(
                children: [
                  AxisHeroPill(info.daysLeftLabel),
                  const SizedBox(width: 7),
                  AxisEventStatusBadge(status: status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteTag extends StatelessWidget {
  const _WhiteTag(this.label, {required this.blue});

  final String label;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: blue ? AppColors.brand : AppColors.neutralText,
        ),
      ),
    );
  }
}

/// 섹션 제목(20 Bold) + 오른쪽 보조 글(12 Medium gray06).
class EventSectionTitle extends StatelessWidget {
  const EventSectionTitle(this.title, {super.key, this.trailing, this.count});

  final String title;

  /// 파란 숫자("1,284명").
  final String? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: count == null
                ? Text(title, style: AxisText.sectionTitle)
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '$title '),
                        TextSpan(
                          text: count,
                          style: const TextStyle(color: AppColors.brand),
                        ),
                      ],
                    ),
                    style: AxisText.sectionTitle.copyWith(color: Colors.black),
                  ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// 섹션 제목 오른쪽의 작은 회색 글("09:00 AM 기준", "공감순").
class EventMeta extends StatelessWidget {
  const EventMeta(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.gray06),
    );
  }
}

/// 유의사항 블록(12 SemiBold #6B7684 제목 + 12 Regular gray06 줄들).
class EventNotice extends StatelessWidget {
  const EventNotice({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '유의사항',
            style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: Color(0xFF6B7684)),
          ),
          const SizedBox(height: 10),
          for (final l in lines) Text('· $l', style: AxisText.caption),
        ],
      ),
    );
  }
}

/// 메이트 프로필(36px 원, 배경색 + 캐릭터).
class MateAvatar extends StatelessWidget {
  const MateAvatar({super.key, required this.character, required this.color, this.size = 36});

  final int character;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Image.asset(AxisAvatar.asset(character), fit: BoxFit.cover, alignment: const Alignment(0, -0.4)),
    );
  }
}

/// 메이트(순위·확언) 데모 데이터.
class Mate {
  const Mate(this.name, this.character, this.color);

  final String name;
  final int character;
  final Color color;
}

const mates = [
  Mate('플랜마스터', 3, CubeColors.orange),
  Mate('새벽러너', 1, AppColors.brand),
  Mate('꾸준함이답', 5, CubeColors.yellow),
  Mate('하루한조각', 7, CubeColors.green),
  Mate('정리왕민수', 9, CubeColors.red),
];
