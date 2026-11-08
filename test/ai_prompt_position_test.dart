import 'package:axis_app/screens/planner/ai_planner_screen.dart';
import 'package:axis_app/screens/planner/planner_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, {double keyboard = 0, double inset = 0}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  tester.view.viewPadding = FakeViewPadding(bottom: inset);
  tester.view.padding = FakeViewPadding(bottom: inset);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: AiPlannerScreen(initialStage: AiPlannerStage.home)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('0801 prompt bar sits 40 above the screen bottom (Figma)', (tester) async {
    await _pump(tester);
    expect(tester.getRect(find.byType(AiPromptField)).bottom, 844 - 40);
  });

  testWidgets('0801 prompt bar keeps 40 on a phone with a 34 home indicator', (tester) async {
    await _pump(tester, inset: 34);
    expect(tester.getRect(find.byType(AiPromptField)).bottom, 844 - 40);
  });

  testWidgets('0801 prompt bar rises 34 above the keyboard and hides the title', (tester) async {
    await _pump(tester, keyboard: 300);
    expect(tester.getRect(find.byType(AiPromptField)).bottom, 844 - 334);
    // 0801_ai온보딩_ 입력: 가운데 제목은 숨고 예시 카드는 입력창 위 30에 남는다.
    expect(find.text('어떤 계획을\n도와드릴까요?'), findsNothing);
    final cards = tester.getRect(find.textContaining('교통사고')).bottom;
    expect(cards, lessThan(844 - 334 - 50));
  });
}
