import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'form_widgets.dart';

/// 로그인·회원가입·정보입력 화면(02~05)의 공통 틀:
/// 하늘색 배경 + 상단 네비(상태 표시줄 아래 10) + 스크롤되는 본문(네비 아래 30) + 하단 고정 버튼(바닥에서 28).
class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.title,
    required this.children,
    required this.bottom,
    this.bottomGap = AppSizes.ctaBottom,
  });

  final String title;
  final List<Widget> children;
  final Widget bottom;

  /// 화면 하단과 버튼 사이 간격(디자인 기준, 홈 인디케이터 영역 포함).
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: DecoratedBox(
            decoration: softBlueBackground,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AxisNavBar(title: title),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 30, AppSizes.sidePadding, 24),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(AppSizes.sidePadding, 0, AppSizes.sidePadding, bottomGap),
                    child: bottom,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 화면 상단 큰 제목(22 Bold).
class PageHeading extends StatelessWidget {
  const PageHeading(this.text, {super.key, this.height = 1.3});

  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        height: height,
        letterSpacing: -0.22,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}

class PageSubheading extends StatelessWidget {
  const PageSubheading(this.text, {super.key, this.color = AppColors.subText});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 14, height: 1.4, color: color));
  }
}
