import 'package:axis_app/widgets/kit/segmented.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Segmented/Tab 2 keeps Figma 149x38 inside a taller header', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [AxisPillSegment(labels: const ['목록', '달성률'], selected: 0, onChanged: (_) {})],
            ),
          ),
        ),
      ),
    );
    final size = tester.getSize(find.byType(AxisPillSegment));
    expect(size.height, 38);
    expect(size.width, closeTo(149, 0.5));
  });
}
