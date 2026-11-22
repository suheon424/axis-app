import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'icons.dart';

/// Timeline/Marker(130:9964)의 상태.
enum AxisMarkerState {
  /// 검정 채움 + 흰 번호.
  normal,

  /// 지금 일정: 파랑 채움 + 하늘색 4px 고리.
  current,

  /// 다가올 일정: 흰 바탕 + 검정 테두리·번호.
  upcoming,

  /// 끝난 일정: 검정 채움 + 흰 체크.
  done,
}

/// Timeline/Marker(130:9964): 25px 원형 순서 표시.
class AxisTimelineMarker extends StatelessWidget {
  const AxisTimelineMarker({super.key, required this.number, this.state = AxisMarkerState.normal});

  final int number;
  final AxisMarkerState state;

  @override
  Widget build(BuildContext context) {
    final fill = switch (state) {
      AxisMarkerState.current => AppColors.brand,
      AxisMarkerState.upcoming => Colors.white,
      _ => AppColors.gray07,
    };
    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: switch (state) {
          AxisMarkerState.current => Border.all(
            color: AppColors.brandSky,
            width: 4,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          AxisMarkerState.upcoming => Border.all(color: AppColors.gray07),
          _ => null,
        },
      ),
      child: state == AxisMarkerState.done
          ? const AxisIcon(KitIcon.checkWhite, size: 18)
          : Text(
              '$number',
              style: TextStyle(
                fontSize: 14,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: state == AxisMarkerState.upcoming ? AppColors.gray07 : Colors.white,
              ),
            ),
    );
  }
}

/// 타임라인 한 줄의 공통 틀: 왼쪽 시간 칸(60) · 가운데 표시(25) · 오른쪽 내용(아래 1px 선).
class _TimelineFrame extends StatelessWidget {
  const _TimelineFrame({required this.leading, required this.marker, required this.content, this.onTap});

  final Widget leading;
  final Widget marker;
  final Widget content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 60,
              child: Align(alignment: Alignment.centerLeft, child: leading),
            ),
            const SizedBox(width: 14),
            SizedBox(width: 25, child: Center(child: marker)),
            const SizedBox(width: 18),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.gray02)),
                ),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _timeStyle = TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.gray07);

/// 제목(16 Medium) + 오른쪽 작은 회색 글(12) 한 줄.
class _TitleLine extends StatelessWidget {
  const _TitleLine({required this.title, this.trailing, this.muted = false});

  final String title;
  final String? trailing;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            title,
            style: AxisText.rowTitleMedium.copyWith(color: muted ? AppColors.gray06 : AppColors.gray07),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), Text(trailing!, style: AxisText.caption)],
      ],
    );
  }
}

/// Timeline/Place Row(130:10042): "08:30 AM" · 번호 마커 · 장소 이름 + 오른쪽 장소 설명.
class AxisTimelinePlaceRow extends StatelessWidget {
  const AxisTimelinePlaceRow({
    super.key,
    required this.time,
    required this.number,
    required this.title,
    this.place,
    this.subtitle,
    this.state = AxisMarkerState.normal,
    this.onTap,
  });

  final String time;
  final int number;
  final String title;

  /// 제목 오른쪽 회색 글(예: "브릿지파트너스").
  final String? place;

  /// 제목 아래 한 줄(선택).
  final String? subtitle;
  final AxisMarkerState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TimelineFrame(
      onTap: onTap,
      leading: Text(time, style: _timeStyle),
      marker: AxisTimelineMarker(number: number, state: state),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TitleLine(title: title, trailing: place),
          if (subtitle != null) Text(subtitle!, style: AxisText.caption),
        ],
      ),
    );
  }
}

/// Timeline/Transit Row(130:10050): 소요 시간·거리 · 교통 아이콘 · 수단(회색 16 Medium) + 구간 + 노선 설명.
class AxisTimelineTransitRow extends StatelessWidget {
  const AxisTimelineTransitRow({
    super.key,
    required this.duration,
    required this.mode,
    this.icon = KitIcon.subway,
    this.route,
    this.detail,
    this.onTap,
  });

  /// 왼쪽 칸 문구(예: "15분 소요\n3.5km").
  final String duration;

  /// 예: "지하철"
  final String mode;

  /// [KitIcon] 이름(subway, busFilled, bus, car, walk).
  final String icon;

  /// 오른쪽 구간(예: "광흥창역 → 공덕역").
  final String? route;

  /// 아래 줄(예: "2호선 공덕 방면").
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TimelineFrame(
      onTap: onTap,
      leading: Text(duration, style: _timeStyle.copyWith(color: AppColors.gray06)),
      marker: Container(
        width: 25,
        height: 25,
        color: Colors.white,
        alignment: Alignment.center,
        child: AxisIcon(icon, size: 16, color: AppColors.gray06),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TitleLine(title: mode, trailing: route, muted: true),
          if (detail != null) Text(detail!, style: AxisText.caption),
        ],
      ),
    );
  }
}

/// Timeline/Start Row(130:10060): 출발 시간 · 집 마커 · "집" + 지역 + "준비 설정 시간 20분"(빨강 강조).
class AxisTimelineStartRow extends StatelessWidget {
  const AxisTimelineStartRow({
    super.key,
    required this.time,
    required this.title,
    this.place,
    this.prepLabel = '준비 설정 시간',
    this.prepValue,
    this.onTap,
  });

  final String time;

  /// 예: "집"
  final String title;

  /// 예: "서울 · 마포구"
  final String? place;
  final String prepLabel;

  /// 예: "20분". null이면 준비 시간 줄을 숨긴다.
  final String? prepValue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TimelineFrame(
      onTap: onTap,
      leading: Text(time, style: _timeStyle),
      marker: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gray07),
        ),
        child: const AxisIcon(KitIcon.homeGlyph, size: 10, color: AppColors.gray07),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TitleLine(title: title, trailing: place),
          if (prepValue != null)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$prepLabel '),
                  TextSpan(
                    text: prepValue,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.error),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w500, color: AppColors.gray07),
            ),
        ],
      ),
    );
  }
}
