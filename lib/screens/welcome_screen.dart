import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/kit/kit_buttons.dart';
import 'login_screen.dart';

/// 01_시작 화면: 소셜 로그인 3종 + 로그인(→ 02 로그인) + 이메일로 로그인하기.
/// 회원가입은 로그인 화면의 "회원가입"으로 들어간다.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  /// [start]~[end] 구간(0~1)에서 아래에서 떠오르며 나타나는 애니메이션.
  Widget _reveal({required double start, required double end, required Widget child, double dy = 16}) {
    final anim = CurvedAnimation(
      parent: _intro,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (context, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(offset: Offset(0, dy * (1 - anim.value)), child: child),
      ),
    );
  }

  void _openLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  /// "이메일로 로그인하기": 시연용 계정이 채워진 로그인 화면(아무 값이나 넣어도 통과).
  void _openEmailLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen(prefill: true)));
  }

  void _comingSoon(String provider) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$provider 로그인은 준비 중이에요.')));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/bg_welcome.png', fit: BoxFit.cover),
            // 로고 영역 (프레임 상단에서 93px)
            Positioned(
              top: 93,
              left: 0,
              right: 0,
              child: _reveal(
                start: 0,
                end: 0.45,
                dy: 24,
                // 로고 130 → 워드마크(로고 아래쪽에 21 겹침) → 27 아래 문구.
                child: Column(
                  children: [
                    Image.asset('assets/images/logo_symbol.png', width: 130, height: 130),
                    Transform.translate(
                      offset: const Offset(0, -21),
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/icons/wordmark_axis.svg', width: 73.6, height: 27.4),
                          const SizedBox(height: 27),
                          const Text(
                            '흔들림 없는 일상의 중심축',
                            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 하단 버튼 영역
            Positioned(
              left: 12,
              right: 12,
              bottom: 46 + (bottomInset > 34 ? bottomInset - 34 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _reveal(
                    start: 0.30,
                    end: 0.65,
                    child: _SocialButton(
                      icon: 'assets/icons/ic_facebook.svg',
                      label: 'Facebook으로 계속하기',
                      onTap: () => _comingSoon('Facebook'),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _reveal(
                    start: 0.38,
                    end: 0.73,
                    child: _SocialButton(
                      icon: 'assets/icons/ic_google.svg',
                      label: 'Google로 계속하기',
                      onTap: () => _comingSoon('Google'),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _reveal(
                    start: 0.46,
                    end: 0.81,
                    child: _SocialButton(
                      icon: 'assets/icons/ic_apple.svg',
                      label: 'Apple로 계속하기',
                      onTap: () => _comingSoon('Apple'),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _reveal(
                    start: 0.54,
                    end: 0.89,
                    child: AxisCtaButton(label: '로그인', onPressed: _openLogin),
                  ),
                  const SizedBox(height: 18),
                  _reveal(
                    start: 0.62,
                    end: 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _openEmailLogin,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '이메일로 로그인하기',
                          style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.5, sigmaY: 12.5),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.buttonHeight),
            width: double.infinity,
            color: Colors.black.withValues(alpha: 0.4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(left: 20, child: SvgPicture.asset(icon, width: 24, height: 24)),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: -0.32,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
