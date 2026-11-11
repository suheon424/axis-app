import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 피그마 "🧩 axis Components > Icon"(130:9421)에서 내보낸 SVG 아이콘 이름.
/// 파일은 assets/icons/kit/<이름>.svg. [AxisIcon]으로 그린다.
///
/// - nav*: 24px 1.8 선 아이콘(기본 gray06). 기능·네비게이션 아이콘 규칙.
/// - small*: 14px 보조 아이콘(북마크·좋아요 on/off, 오른쪽 화살표).
/// - menu*: 18px 마이 메뉴 아이콘(검정).
/// - 나머지(heart, alarm, calendar, clock, trash, bus, car, walk, question, checkBox, filter, plusBold,
///   subway, busFilled, swipeRight, shareGraph): 흰색 채움 아이콘. [AxisIcon.color]로 다시 칠해 쓴다.
abstract final class KitIcon {
  static const navBack = 'nav_back';
  static const navShare = 'nav_share';
  static const navBookmark = 'nav_bookmark';
  static const navBookmarkOn = 'nav_bookmark_on';
  static const navPlus = 'nav_plus';
  static const navClose = 'nav_close';
  static const navMore = 'nav_more';
  static const navExpand = 'nav_expand';
  static const navBell = 'nav_bell';
  static const navSearch = 'nav_search';
  static const stateAlert = 'state_alert';
  static const statePoint = 'state_point';

  static const smallBookmarkOff = 'small_bookmark_off';
  static const smallBookmarkOn = 'small_bookmark_on';
  static const smallLikeOff = 'small_like_off';
  static const smallLikeOn = 'small_like_on';
  static const smallChevronRight = 'small_chevron_right';
  static const chevronDownSmall = 'chevron_down_small';
  static const clockSmall = 'clock_small';
  static const helpful = 'helpful';

  static const menuBadge = 'menu_badge';
  static const menuPost = 'menu_post';
  static const menuComment = 'menu_comment';
  static const menuBookmark = 'menu_bookmark';
  static const menuNotice = 'menu_notice';
  static const menuAlarm = 'menu_alarm';
  static const menuSupport = 'menu_support';
  static const menuInfo = 'menu_info';

  static const heartOn = 'heart_on';
  static const heartOff = 'heart_off';
  static const plusBold = 'plus_bold';
  static const filter = 'filter';
  static const alarmOn = 'alarm_on';
  static const alarmOff = 'alarm_off';
  static const calendar = 'calendar';
  static const clock = 'clock';

  /// 장소 카드(130:11195)의 선 시계(18px, 1.4 선).
  static const clockLine = 'clock_line';
  static const trash = 'trash';
  static const bus = 'bus';
  static const busFilled = 'bus_filled';
  static const car = 'car';
  static const walk = 'walk';
  static const subway = 'subway';
  static const question = 'question';
  static const checkBox = 'check_box';
  static const checkWhite = 'check_white';
  static const shareGraph = 'share_graph';
  static const swipeRight = 'swipe_right';
  static const repeat = 'repeat';
  static const panZoom = 'pan_zoom';
  static const homeGlyph = 'home_glyph';
  static const aiSparkle = 'ai_sparkle';
  static const lock = 'lock';

  static String path(String name) => 'assets/icons/kit/$name.svg';
}

/// [KitIcon] 아이콘 하나. [color]를 주면 그 색으로 다시 칠한다(선·채움 모두).
class AxisIcon extends StatelessWidget {
  const AxisIcon(this.name, {super.key, this.size = 24, this.color, this.semanticLabel});

  final String name;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      KitIcon.path(name),
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

/// 오른쪽을 가리키는 화살표(Icon/Nav/Back을 뒤집어 쓴다. 목록 줄 끝·카드 머리).
class AxisChevronRight extends StatelessWidget {
  const AxisChevronRight({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: true,
      child: AxisIcon(KitIcon.navBack, size: size, color: color),
    );
  }
}
