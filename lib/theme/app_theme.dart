import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Figma 변수(gray01~09, cube_color02 등)를 그대로 옮긴 색상 토큰.
abstract final class AppColors {
  static const gray04 = Color(0xFFBDC3D0);
  static const gray05 = Color(0xFFA3AAB5);
  static const gray06 = Color(0xFF636C78);
  static const gray07 = Color(0xFF1F2027);
  static const gray09 = Color(0xFF0F1014);
  static const primary = Color(0xFF0057ED); // cube_color02
  static const subText = Color(0xFF7B8797);
  static const hint = Color(0xFF868686);
  static const muted = Color(0xFF949494);
  static const chipBorder = Color(0xFFDDDFEA);
  static const skipBg = Color(0xFFEDEEF1);
  static const skipText = Color(0xFF939393);
  static const searchBg = Color(0xFFF4F5FA);
  static const searchBorder = Color(0xFFC1C1C1);
  static const gray03 = Color(0xFFCCD1DD);
  static const icon = Color(0xFF33363D);

  // 2026-10 개선안 토큰
  static const gray02 = Color(0xFFEDEEF6);
  static const error = Color(0xFFE00000); // cube_color06
  static const blue01 = Color(0xFFD3EBFF); // bule01: 선택된 칩·옵션 배경
  static const text = Color(0xFF191F28); // 입력값
  static const body = Color(0xFF636B78); // 본문 보조 문구
  static const caption = Color(0xFF8A919E); // 안내·도움말
  static const line = Color(0xFFC4CAD3); // 값이 있는 입력창 밑줄
  static const divider = Color(0xFFE4E7EC);
  static const checkboxBorder = Color(0xFFB8BEC8);
  static const stepperBg = Color(0xFFF4F5F8);
}

/// 디자인의 공통 수치.
/// 흰 화면: 상단 표시줄을 흰 바탕·검정 글씨로. 웹에서는 statusBarColor가 theme-color가 되어
/// 홈 화면에 추가한 앱의 표시줄 바탕도 화면마다 바뀐다.
const lightScreenOverlay = SystemUiOverlayStyle(
  statusBarColor: Colors.white,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

/// 어두운 화면(첫 화면 등): 검정 바탕·흰 글씨.
const darkScreenOverlay = SystemUiOverlayStyle(
  statusBarColor: Colors.black,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

abstract final class AppSizes {
  static const buttonHeight = 52.0; // Button/Primary
  static const sidePadding = 20.0;
  static const navHeight = 40.0;
}

/// 로그인/회원가입 화면의 오른쪽에서 퍼지는 하늘색 배경.
const softBlueBackground = BoxDecoration(
  gradient: RadialGradient(
    center: Alignment(1.0, -0.04),
    radius: 0.78,
    colors: [Color(0xFFA0D5FF), Color(0xFFD0EAFF), Colors.white],
    stops: [0.0, 0.5, 1.0],
  ),
);

/// Figma Button/Primary의 conic-gradient 채움을 근사한 그라디언트.
/// 왼쪽은 파랑, 오른쪽 3/4 지점에 어두운 사선, 그 뒤로 밝은 파랑(디자인 픽셀 값을 샘플링해 맞춤).
const brandButtonGradient = LinearGradient(
  begin: Alignment(-1, -4.67),
  end: Alignment(1, 4.67),
  colors: [
    Color(0xFF004FD6),
    Color(0xFF004DD2),
    Color(0xFF004BCC),
    Color(0xFF0046BF),
    Color(0xFF0040B3),
    Color(0xFF003CAA),
    Color(0xFF004CD2),
    Color(0xFF005EFE),
    Color(0xFF0562FE),
    Color(0xFF0763FE),
  ],
  stops: [0.0, 0.2, 0.5, 0.62, 0.67, 0.7, 0.73, 0.76, 0.87, 1.0],
);

/// 01 첫 화면 "가입하기" 버튼의 conic-gradient 채움을 근사한 그라디언트.
/// 왼쪽은 남색, 가운데 오른쪽에 어두운 사선, 오른쪽 끝은 밝은 파랑(디자인 픽셀 값을 샘플링해 맞춤).
const welcomeButtonGradient = LinearGradient(
  begin: Alignment(-0.857, 2.0),
  end: Alignment(0.286, -6.0),
  colors: [
    Color(0xFF013EA4),
    Color(0xFF013690),
    Color(0xFF033283),
    Color(0xFF022B74),
    Color(0xFF03245C),
    Color(0xFF03296C),
    Color(0xFF023388),
    Color(0xFF0048C0),
    Color(0xFF0A58D8),
    Color(0xFF1161E4),
    Color(0xFF1666ED),
  ],
  stops: [0.0, 0.125, 0.375, 0.5, 0.6, 0.6875, 0.7425, 0.805, 0.8675, 0.93, 1.0],
);

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Pretendard',
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
    scaffoldBackgroundColor: Colors.white,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    // Figma 프로토타입의 기본 이동(오른쪽에서 밀려 들어오기)을 두 플랫폼 모두 같게 맞춘다.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primary),
  );
  return base.copyWith(
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.gray07,
    ),
  );
}
