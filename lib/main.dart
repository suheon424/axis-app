import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/community/community_screen.dart';
import 'screens/badge/badge_storage_screen.dart';
import 'screens/event/event_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my/my_page_screen.dart';
import 'screens/planner/ai_planner_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/main_chrome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  registerMainTabs();
  runApp(const AxisApp());
}

/// 하단 탭마다 첫 화면을 등록한다. 화면 파일끼리 서로 import하지 않도록 여기서 한 번에 잇는다.
void registerMainTabs() {
  MainTabRouter.builders
    ..[MainTab.home] = ((_) => const HomeScreen())
    ..[MainTab.planner] = ((_) => const AiPlannerScreen())
    ..[MainTab.explore] = ((_) => const CommunityScreen())
    ..[MainTab.event] = ((_) => const EventScreen())
    ..[MainTab.my] = ((_) => const MyPageScreen());
  MyPageScreen.openBadges = (_) => const BadgeStorageScreen();
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
