import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const AxisApp());
}

class AxisApp extends StatelessWidget {
  const AxisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'axis',
      // 웹에서는 시작할 때 이 색이 상단 표시줄 색(theme-color)이 된다. 첫 화면이 어두워 검정.
      // 이후에는 각 화면의 AnnotatedRegion(lightScreenOverlay / darkScreenOverlay)이 바꾼다.
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const WelcomeScreen(),
    );
  }
}
