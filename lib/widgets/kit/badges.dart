import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';
import 'progress.dart';

/// Badge/Tag(130:10301)의 색 조합.
enum AxisTagTone {
  red(Color(0xFFFFF0F0), Color(0xFFE00000)),
  green(Color(0xFFE9F7F1), Color(0xFF009156)),
  blue(Color(0xFFEAF2FF), Color(0xFF004FED)),
  orange(Color(0xFFFFF4E6), Color(0xFFE8590C)),
  gray(Color(0xFFF2F4F6), Color(0xFF6B7684)),
  neutral(Color(0xFFF4F5FA), Color(0xFF4E5968)),
  dark(Color(0xFF191F28), Colors.white);

  const AxisTagTone(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

/// Badge/Tag(130:10301): 굴곡 4 상태 태그(12 SemiBold, neutral·dark는 Medium).
class AxisTag extends StatelessWidget {
  const AxisTag(this.label, {super.key, this.tone = AxisTagTone.blue});

  final String label;
  final AxisTagTone tone;

  @override
  Widget build(BuildContext context) {
    final medium = tone == AxisTagTone.neutral || tone == AxisTagTone.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: tone.background, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          fontWeight: medium ? FontWeight.w500 : FontWeight.w600,
          color: tone.foreground,
        ),
      ),
    );
  }
}

enum AxisEventStatus { joined, join, done }

/// Badge/Event Status(130:10231): 참여 중(연파랑) / 참여하기(파랑) / 참여 완료(회색). 높이 24.
class AxisEventStatusBadge extends StatelessWidget {
  const AxisEventStatusBadge({super.key, required this.status});

  final AxisEventStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      AxisEventStatus.joined => ('참여 중', AppColors.brandSoft, AppColors.brand),
      AxisEventStatus.join => ('참여하기', AppColors.brand, Colors.white),
      AxisEventStatus.done => ('참여 완료', const Color(0xFFF2F4F6), AppColors.gray06),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// Badge/Hero Pill(130:10318) Type=Period: 사진·배너 위 검정 알약(예: "7일 남음").
/// [muted]는 반투명 검정(Status Muted 대용).
class AxisHeroPill extends StatelessWidget {
  const AxisHeroPill(this.label, {super.key, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: muted ? const Color(0x99000000) : Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

/// Badge/Number(130:10325): 20px 원형 번호. dark(검정·그림자) / blue(파랑·흰 테두리·파란 빛).
class AxisNumberBadge extends StatelessWidget {
  const AxisNumberBadge(this.number, {super.key, this.blue = false});

  final int number;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: blue ? AppColors.brand : AppColors.gray07,
        borderRadius: BorderRadius.circular(100),
        border: blue ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: blue
            ? const [BoxShadow(color: AppColors.brand, blurRadius: 20, spreadRadius: 2)]
            : const [BoxShadow(color: Color(0x99000000), blurRadius: 4)],
      ),
      child: Text(
        '$number',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

/// Badge/Rank(130:10332): 카드 왼쪽 위 순위 꼬리표(굴곡 8,0,8,0). top은 파랑, 나머지는 검정 85%.
class AxisRankBadge extends StatelessWidget {
  const AxisRankBadge(this.rank, {super.key, this.top = false});

  final int rank;
  final bool top;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: top ? AppColors.brand : const Color(0xD9191F28),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Text(
        '$rank',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

/// Badge/Notification(130:10337): 빨간 16px 알림 점. [count]가 없으면 "N"(새 소식).
class AxisNotificationBadge extends StatelessWidget {
  const AxisNotificationBadge({super.key, this.count});

  static const _nudge = 0.25;

  final int? count;

  @override
  Widget build(BuildContext context) {
    final text = count == null ? 'N' : (count! > 99 ? '99+' : '$count');
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: count == null ? const Color(0xFFE5484D) : AppColors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      // 피그마 New는 9pt이지만 앱 최소 글자 크기(12)를 따른다.
      // 대문자·숫자는 글꼴 칸 안에서 위로 쏠려 보여서, 줄 높이를 글자 크기로 맞추고 시각 중심만큼 내린다.
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Transform.translate(
          offset: const Offset(0, _nudge),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1,
              leadingDistribution: TextLeadingDistribution.even,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge/Compare(130:10342): Before(회색) / After(파랑) 알약. 높이 16.
class AxisCompareBadge extends StatelessWidget {
  const AxisCompareBadge({super.key, required this.after, this.label});

  final bool after;

  /// 기본 "Before" / "After".
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: after ? AppColors.brand : AppColors.subIcon,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label ?? (after ? 'After' : 'Before'),
        style: const TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: Colors.white),
      ),
    );
  }
}

/// Badge/Medal(130:10347)의 9가지 3D 메탈 배지. 이미지는 assets/images/kit/medal_*.png(210px).
enum AxisMedal {
  awakening('각성의 순간', 'awakening'),
  primeAxis('프라임 액시스', 'prime_axis'),
  flowCenter('흐름의 중심', 'flow_center'),
  firstStep('중심의 첫걸음', 'first_step'),
  coordSharer('좌표 공유자', 'coord_sharer'),
  shareSprout('공유 새싹', 'share_sprout'),
  dawnAxis('새벽의 축', 'dawn_axis'),
  focusOrbit('몰입의 궤도', 'focus_orbit'),
  perfectWeek('완벽한 한 주', 'perfect_week');

  const AxisMedal(this.title, this.file);

  final String title;
  final String file;

  String get asset => 'assets/images/kit/medal_$file.png';
}

/// Badge/Medal 이미지 한 개(기본 70px).
class AxisMedalImage extends StatelessWidget {
  const AxisMedalImage(this.medal, {super.key, this.size = 70});

  final AxisMedal medal;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(medal.asset, width: size, height: size, semanticLabel: medal.title);
  }
}

/// Badge/Item(130:10286): 배지 그림 + 이름(14 SemiBold) + 설명(12 gray06).
/// 잠김([progress]가 있으면 잠김으로 본다): 그림 40% + 자물쇠 + 미니 바.
class AxisBadgeItem extends StatelessWidget {
  const AxisBadgeItem({super.key, required this.medal, required this.caption, this.progress, this.name});

  final AxisMedal medal;
  final String caption;

  /// 잠긴 배지의 진행도(0~1). null이면 획득한 배지.
  final double? progress;

  /// 기본은 [AxisMedal.title].
  final String? name;

  @override
  Widget build(BuildContext context) {
    final locked = progress != null;
    return SizedBox(
      width: 104,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(opacity: locked ? 0.4 : 1, child: AxisMedalImage(medal)),
                if (locked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.neutralText,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(child: AxisIcon(KitIcon.lock, size: 10)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name ?? medal.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.gray07),
          ),
          const SizedBox(height: 8),
          if (locked) ...[AxisMiniBar(value: progress!), const SizedBox(height: 4)],
          Text(caption, textAlign: TextAlign.center, style: AxisText.caption),
        ],
      ),
    );
  }
}
