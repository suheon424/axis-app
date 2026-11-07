import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';
import 'badge_data.dart';
import 'badge_storage_screen.dart';

/// 11-1_배지 획득 축하(130:13419)를 지금 화면 위에 띄운다.
/// 어두운 덮개 + 축하 카드 + "이미지 저장" 알약 + 아래 "공유하기". 카드를 누르면 배지 보관함으로 간다.
/// [message]가 없으면 배지의 획득 조건으로 문구를 만든다.
Future<void> showBadgeCelebration(BuildContext context, {required AxisMedal medal, String? message}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '닫기',
    barrierColor: const Color(0xB80A0D12),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (context, _, _) => BadgeCelebration(medal: medal, message: message),
    transitionBuilder: (context, anim, _, child) => FadeTransition(opacity: anim, child: child),
  );
}

/// 배지 획득 축하 덮개의 내용. 보통은 [showBadgeCelebration]으로 띄운다.
class BadgeCelebration extends StatelessWidget {
  const BadgeCelebration({super.key, required this.medal, this.message});

  final AxisMedal medal;
  final String? message;

  void _openStorage(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(MaterialPageRoute<void>(builder: (_) => const BadgeStorageScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final text =
        message ??
        (medal == AxisMedal.awakening ? '일정을 7회 완료했어요. 꾸준함이 시작됐어요!' : '‘${badgeFor(medal).condition}’ 조건을 달성했어요!');
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).pop()),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutBack,
                  builder: (context, s, child) => Transform.scale(scale: s, child: child),
                  child: Semantics(
                    button: true,
                    label: '배지 보관함 열기',
                    child: GestureDetector(
                      onTap: () => _openStorage(context),
                      child: _Card(medal: medal, message: text),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                _SaveImagePill(onTap: () => showAxisToast(context, '이미지를 저장했어요', bottom: 100)),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: (bottom > 0 ? bottom : 27),
            child: AxisCtaButton(
              label: '공유하기',
              onPressed: () => showAxisToast(context, '배지 카드 링크를 복사했어요', bottom: 100),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.medal, required this.message});

  final AxisMedal medal;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      constraints: const BoxConstraints(minHeight: 340),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.3, 1),
          colors: [Color(0xFF2F6FF0), Color(0xFFA9D3FF), Color(0xFFF5FAFF)],
          stops: [0, 0.4, 1],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            height: 194,
            child: medal == AxisMedal.awakening
                ? Image.asset('assets/images/event/badge_celebrate_awakening.png', semanticLabel: medal.title)
                : Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateX(0.5)
                        ..rotateZ(-math.pi / 5),
                      child: AxisMedalImage(medal, size: 130),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '축하합니다!\n'),
                TextSpan(
                  text: medal.title,
                  style: const TextStyle(color: AppColors.brand),
                ),
                const TextSpan(text: ' 배지를 받았어요.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: AxisText.title18.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.36, fontWeight: FontWeight.w500, color: AppColors.gray07),
          ),
          const SizedBox(height: 22),
          SvgPicture.asset(
            'assets/icons/wordmark_axis.svg',
            height: 18,
            colorFilter: const ColorFilter.mode(AppColors.gray05, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

/// 반투명 흰 알약(굴곡 20, 흰 1px 테두리) "이미지 저장".
class _SaveImagePill extends StatelessWidget {
  const _SaveImagePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: '이미지 저장',
      onTap: onTap,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: pressed ? 0.24 : 0.14),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: Colors.white),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text('이미지 저장', style: AxisText.button),
          ],
        ),
      ),
    );
  }
}
