import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show ImageFilter;

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
                const SizedBox(height: 14),
                _SaveImagePill(onTap: () => showAxisToast(context, '이미지를 저장했어요', bottom: 100)),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: AppSizes.ctaBottom,
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

/// 축하 카드 위쪽(220×194)에 들어가는 배지 그림. 없으면 메달 이미지를 비스듬히 눕혀 쓴다.
/// 각성의 순간은 11_뱃지획득(130:13424)에 들어간 움직이는 GIF(피그마 크롭 그대로 330×291)를 쓴다.
const _celebrateArt = {AxisMedal.awakening: 'assets/images/event/badge_celebrate_awakening.gif'};

class _Card extends StatelessWidget {
  const _Card({required this.medal, required this.message});

  final AxisMedal medal;
  final String message;

  @override
  Widget build(BuildContext context) {
    // Frame 53(320×351, 굴곡 24): 배지 그림(위 10) → 제목(18 Bold) → 설명(12 Medium) → axis 로고, 오른쪽 위 Button/Close.
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CustomPaint(
        painter: const _CardGradientPainter(),
        child: Stack(
          children: [
            Container(
              width: 320,
              constraints: const BoxConstraints(minHeight: 351),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 19),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 220,
                    height: 194,
                    child: _celebrateArt[medal] != null
                        ? Image.asset(
                            _celebrateArt[medal]!,
                            fit: BoxFit.fill,
                            gaplessPlayback: true,
                            semanticLabel: medal.title,
                          )
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
                    style: const TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.36,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2027),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SvgPicture.asset(
                    'assets/icons/logo_axis_gray.svg',
                    width: 60,
                    height: 16,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
            ),
            Positioned(top: 24, right: 20, child: AxisCloseButton(onPressed: () => Navigator.of(context).pop())),
          ],
        ),
      ),
    );
  }
}

/// Frame 53의 채우기 세 겹을 피그마 gradientTransform 그대로 그린다.
/// 아래부터: 세로 선형(#D3EBFF → 흰색), 하늘색 원형 빛(#A0D5FF), 왼쪽 위 파란 원형 빛(#004FED).
class _CardGradientPainter extends CustomPainter {
  const _CardGradientPainter();

  static const _layers = <(List<double>, Gradient)>[
    (
      [
        -1.25420229757367e-9,
        1.7353096008300781,
        -0.7353096008300781,
        -1.7353096008300781,
        5.273559366969494e-16,
        1.367654800415039,
      ],
      LinearGradient(begin: Alignment(-1, 0), end: Alignment(1, 0), colors: [Color(0xFFD3EBFF), Color(0xFFFFFFFF)]),
    ),
    (
      [
        -0.20555274188518524,
        0.3133062720298767,
        0.6865079402923584,
        -0.20565979182720184,
        -0.2014390528202057,
        0.701558530330658,
      ],
      RadialGradient(colors: [Color(0xFFA0D5FF), Color(0x00FFFFFF)]),
    ),
    (
      [0.20042461156845093, 0.29939785599708557, 0.5, -0.1965300589799881, 0.1964135766029358, 0.5],
      RadialGradient(colors: [Color(0xFF004FED), Color(0x00FFFFFF)]),
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (t, gradient) in _layers) {
      // t는 (0~1로 맞춘 칸 좌표) → (그라디언트 단위 사각형) 변환. 그 역으로 단위 사각형을 칸 위에 놓는다.
      final a = t[0], b = t[1], c = t[2], d = t[3], e = t[4], f = t[5];
      final det = a * e - b * d;
      final ia = e / det, ib = -b / det, id = -d / det, ie = a / det;
      final ic = -(ia * c + ib * f), iff = -(id * c + ie * f);
      canvas.save();
      canvas.scale(size.width, size.height);
      canvas.transform(Float64List.fromList([ia, id, 0, 0, ib, ie, 0, 0, 0, 0, 1, 0, ic, iff, 0, 1]));
      const unit = Rect.fromLTWH(0, 0, 1, 1);
      canvas.drawRect(const Rect.fromLTWH(-20, -20, 41, 41), Paint()..shader = gradient.createShader(unit));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CardGradientPainter old) => false;
}

/// Frame 76: 검정 40% 알약(130×40, 굴곡 20, 배경 흐림 10) "이미지 저장".
class _SaveImagePill extends StatelessWidget {
  const _SaveImagePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressBuilder(
      semanticLabel: '이미지 저장',
      onTap: onTap,
      builder: (context, pressed) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            color: Colors.black.withValues(alpha: pressed ? 0.55 : 0.4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/icons/list_download.svg', width: 18, height: 18),
                const SizedBox(width: 8),
                const Text('이미지 저장', style: AxisText.button),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
