import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/buttons.dart';
import 'welcome_screen.dart';

/// 가입/로그인 이후 도착 화면. Figma에 홈 디자인이 아직 없어 첫 화면의 브랜드 요소로 임시 구성했다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.nickname});

  final String nickname;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/bg_welcome.png', fit: BoxFit.cover),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Column(
                  children: [
                    const Spacer(),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      builder: (context, v, child) =>
                          Opacity(opacity: v.clamp(0.0, 1.0), child: Transform.scale(scale: v, child: child)),
                      child: Image.asset('assets/images/logo_symbol.png', width: 130, height: 130),
                    ),
                    SvgPicture.asset('assets/icons/wordmark_axis.svg', width: 80, height: 29.74),
                    const SizedBox(height: 24),
                    Text(
                      '$nickname님, 준비가 끝났어요!',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const Spacer(flex: 2),
                    BrandButton(
                      label: '처음 화면으로',
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
