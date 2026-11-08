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

  testWidgets('0801 prompt bar rises above the keyboard', (tester) async {
    await _pump(tester, keyboard: 300);
    expect(tester.getRect(find.byType(AiPromptField)).bottom, 844 - 308);
  });
}
