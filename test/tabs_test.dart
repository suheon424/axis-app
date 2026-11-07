import 'package:axis_app/main.dart';
import 'package:axis_app/screens/community/community_screen.dart';
import 'package:axis_app/screens/event/event_screen.dart';
import 'package:axis_app/screens/home_screen.dart';
import 'package:axis_app/screens/my/my_page_screen.dart';
import 'package:axis_app/screens/planner/ai_planner_screen.dart';
import 'package:axis_app/widgets/kit/kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _settle(WidgetTester tester, [int frames = 30]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('Pretendard');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/fonts/Pretendard-$w.otf'));
    }
    await loader.load();
    registerMainTabs();
  });

  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844) * 3;
    view.devicePixelRatio = 3;
  });

  testWidgets('하단 탭 5개가 각 탭 첫 화면으로 바뀐다', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const HomeScreen()));
    await _settle(tester);

    Future<void> tapTab(String label) async {
      await tester.tap(find.descendant(of: find.byType(AxisTabBar), matching: find.text(label)).first);
      await _settle(tester);
    }

    await tapTab('AI 플래너');
    expect(find.byType(AiPlannerScreen), findsOneWidget);
    // AI 플래너(08 · 0801 · 0802)에는 탭 바가 없다. 소개를 눌러 건너뛰고 뒤로 가면 홈으로 돌아온다.
    expect(find.byType(AxisTabBar), findsNothing);
    await tester.tap(find.text('무엇이든 물어보세요'));
    await _settle(tester);
    expect(find.byType(AxisTabBar), findsNothing);
    await tester.tap(find.byType(AxisIconButton).first);
    await _settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    await tapTab('탐색');
    expect(find.byType(CommunityScreen), findsOneWidget);
    await tapTab('이벤트');
    expect(find.byType(EventScreen), findsOneWidget);
    await tapTab('마이');
    expect(find.byType(MyPageScreen), findsOneWidget);
    await tapTab('홈');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
