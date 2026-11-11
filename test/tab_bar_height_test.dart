import 'package:axis_app/widgets/main_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final inset in [0.0, 34.0]) {
    testWidgets('Tab Bar is Figma 92 tall with bottom inset $inset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              padding: EdgeInsets.only(bottom: inset),
            ),
            child: const Scaffold(
              bottomNavigationBar: AxisTabBar(current: MainTab.event, onTap: _noop),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(AxisTabBar)).height, 92);
    });
  }
}

void _noop(MainTab _) {}
