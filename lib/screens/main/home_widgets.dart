import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

/// 07 홈 화면들이 함께 쓰는 조각(목록/달성률 토글, 단계 바, 배경 사진).

/// 07 배경 사진(image 37). 검정 위에 낮은 불투명도로 깐다.
const homeBgPhoto = 'assets/images/main/home_bg_photo.jpg';

/// 화면을 밀어 넣는 애니메이션 없이 바로 바꾼다(목록 ↔ 달성률 토글).
void homeSwitchTo(BuildContext context, Widget screen) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => screen,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

/// 상단 "목록 | 달성률" 알약 토글.
class HomeSegmentToggle extends StatelessWidget {
  const HomeSegmentToggle({
    super.key,
    required this.achievement,
    required this.onChanged,
    this.background = const Color(0x80454D58),
  });

  /// true면 "달성률"이 선택된 상태.
  final bool achievement;
  final ValueChanged<bool> onChanged;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(label: '목록', selected: !achievement, onTap: () => onChanged(false)),
          const SizedBox(width: 2),
          _Segment(label: '달성률', selected: achievement, onTap: () => onChanged(true)),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: selected ? null : onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: selected ? null : onTap,
        child: Container(
          width: 66,
          constraints: const BoxConstraints(minHeight: 28),
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          alignment: Alignment.center,
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 1, offset: Offset(0, 2))],
                )
              : null,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.gray09 : AppColors.gray02,
            ),
          ),
        ),
      ),
    );
  }
}

/// 상단 줄: 왼쪽 axis 로고, 가운데 토글, (있으면) 오른쪽 + 버튼. 높이 48.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, required this.toggle, this.onAdd});

  final Widget toggle;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 가운데 정렬 Column 안에서도 화면 폭을 차지해야 로고가 잘리지 않는다.
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            child: SvgPicture.asset('assets/icons/wordmark_axis.svg', width: 53.8, height: 20),
          ),
          toggle,
          if (onAdd != null)
            Positioned(
              right: 4,
              child: IconButton(
                tooltip: '일정 추가',
                onPressed: onAdd,
                icon: SvgPicture.asset('assets/icons/home_ic_plus.svg', width: 24, height: 24),
              ),
            ),
        ],
      ),
    );
  }
}

/// 단계 바: 끝낸 칸은 파랑, 남은 칸은 반투명 흰색.
class HomeStepBar extends StatelessWidget {
  const HomeStepBar({
    super.key,
    required this.total,
    required this.done,
    this.gap = 4,
    this.todoColor = const Color(0x1FFFFFFF),
  });

  final int total;
  final int done;
  final double gap;
  final Color todoColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              decoration: BoxDecoration(
                color: i < done ? AppColors.primary : todoColor,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 어두운 카드 안의 "Button/Secondary (dark)" (높이 40).
class HomeDarkButton extends StatelessWidget {
  const HomeDarkButton({
    super.key,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    this.color = const Color(0x26FFFFFF),
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 40,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: child,
        ),
      ),
    );
  }
}
