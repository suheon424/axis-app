import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
}

/// 디자인의 공통 수치.
abstract final class AppSizes {
  static const buttonHeight = 50.0; // --bt_height
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

/// Figma의 conic-gradient 버튼 채움을 근사한 그라디언트.
/// 왼쪽은 남색, 가운데 오른쪽에 어두운 사선, 오른쪽 끝은 밝은 파랑(디자인 픽셀 값을 샘플링해 맞춤).
const brandButtonGradient = LinearGradient(
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
