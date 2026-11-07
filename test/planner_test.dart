import 'dart:io';

import 'package:axis_app/screens/planner/ai_planner_screen.dart';
import 'package:axis_app/screens/planner/planner_widgets.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _settle(WidgetTester tester, [int ms = 800]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// SHOT_DIR 환경 변수가 있으면 화면을 PNG로 남긴다(flutter test --update-goldens로 실행).
Future<void> _shot(WidgetTester tester, String name) async {
  final dir = Platform.environment['SHOT_DIR'];
  if (dir == null) return;
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
    final ctx = tester.element(find.byType(Scaffold).first);
    await precacheImage(const AssetImage(AiPlannerBackground.asset), ctx);
  });
  await tester.pump();
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('$dir/$name.png'));
}

Future<void> _open(WidgetTester tester, {AiPlannerStage? stage = AiPlannerStage.home}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: AiPlannerScreen(initialStage: stage),
    ),
  );
  await _settle(tester);
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('Pretendard');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/fonts/Pretendard-$w.otf'));
    }
    await loader.load();
  });

  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844) * 3;
    view.devicePixelRatio = 3;
  });

  testWidgets('처음 열면 08 소개가 보였다가 0801로 넘어간다', (tester) async {
    await _open(tester, stage: null);
    expect(find.text('무엇이든 물어보세요'), findsOneWidget);
    expect(find.text('axis가 해결해드릴게요!'), findsOneWidget);
    expect(find.text('AI 플래너'), findsNothing); // 08에서는 탭 바가 없다.
    await _shot(tester, 'planner_08');
    await _settle(tester, 6800);
    expect(find.text('무엇이든 물어보세요'), findsNothing);
    expect(find.text('어떤 계획을\n도와드릴까요?'), findsOneWidget);
    expect(find.text('이렇게 요청해 보세요'), findsOneWidget);
    expect(find.text('AI 플래너'), findsNothing); // 0801 · 0802도 탭 바가 없다.
    await _shot(tester, 'planner_0801');

    // 두 번째부터는 바로 0801.
    await _open(tester, stage: null);
    expect(find.text('어떤 계획을\n도와드릴까요?'), findsOneWidget);
  });

  testWidgets('요청을 보내면 0802 대화로 바뀌고 제안에 동의할 수 있다', (tester) async {
    await _open(tester);
    const ask = '여행 가기로 했는데 태풍이 와서 일정이 취소됐어\n일정을 어떻게 수정하는 게 좋을까?';
    await tester.enterText(find.byType(TextField), ask);
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('보내기'));
    await _settle(tester, 1500);
    expect(find.text(ask), findsOneWidget);
    expect(find.textContaining('내일 하기로 했던 스터디를'), findsOneWidget);
    expect(find.text('어떤 계획을\n도와드릴까요?'), findsNothing);
    await _shot(tester, 'planner_0802');

    await tester.tap(find.text('동의'));
    await _settle(tester, 300);
    expect(find.text('오늘 일정표를 수정했어요'), findsOneWidget);
    await _settle(tester, 2600);

    await tester.tap(find.bySemanticsLabel('뒤로'));
    await _settle(tester);
    expect(find.text('어떤 계획을\n도와드릴까요?'), findsOneWidget);
  });

  testWidgets('예시 카드를 누르면 그 요청으로 대화가 시작된다', (tester) async {
    await _open(tester);
    await tester.tap(find.text(aiSuggestions.first));
    await _settle(tester, 1500);
    expect(find.text(aiSuggestions.first.replaceAll('\n', ' ')), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
  });
}
