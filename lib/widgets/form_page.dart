import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'form_widgets.dart';

/// 로그인·회원가입·정보입력 화면(02~05)의 공통 틀:
/// 하늘색 배경 + 상단 네비 + 스크롤되는 본문 + 하단 고정 버튼.
class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.title,
    required this.children,
    required this.bottom,
    this.bottomGap = 30,
  });

  final String title;
  final List<Widget> children;
  final Widget bottom;

  /// 화면 하단과 버튼 사이 간격(디자인 기준, 홈 인디케이터 영역 포함).
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
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
                  const SizedBox(height: 4),
                  AxisNavBar(title: title),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 46, AppSizes.sidePadding, 24),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.sidePadding,
                      0,
                      AppSizes.sidePadding,
                      safeBottom > bottomGap ? safeBottom : bottomGap,
                    ),
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

/// 화면 상단 큰 제목.
class PageHeading extends StatelessWidget {
  const PageHeading(this.text, {super.key, this.weight = FontWeight.w700});

  final String text;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 23, height: 1.4, fontWeight: weight, letterSpacing: -0.46, color: Colors.black),
    );
  }
}

class PageSubheading extends StatelessWidget {
  const PageSubheading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.subText));
  }
}
