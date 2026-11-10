import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';

/// 화면 아래 고정 CTA 띠: 흰 바탕 + 위 1px #F2F4F6, 위 10 · 아래 홈 인디케이터만큼 여백.
class BottomCtaBar extends StatelessWidget {
  const BottomCtaBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF2F4F6))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, AppSizes.ctaBottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
      ),
    );
  }
}

/// 정보 줄 오른쪽 상태 꼬리표(Badge/Event Status 변형, 최소 높이 30·굴곡 4).
class InfoTag extends StatelessWidget {
  const InfoTag(this.label, {super.key, this.blue = true});

  final String label;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: blue ? AppColors.brandSoft : const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: blue ? AppColors.brand : AppColors.gray06,
        ),
      ),
    );
  }
}

/// 22px 자물쇠 원(잠긴 배지 표시). [size] 28이면 상세 화면용.
class LockDot extends StatelessWidget {
  const LockDot({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neutralText,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size / 14.7),
      ),
      child: Center(child: AxisIcon(KitIcon.lock, size: size * 10 / 22)),
    );
  }
}

/// 20 Bold 제목 + 파란 숫자("획득한 배지 6", "모은 배지 2/4").
class CountTitle extends StatelessWidget {
  const CountTitle(this.title, this.count, {super.key});

  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
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
    );
  }
}
