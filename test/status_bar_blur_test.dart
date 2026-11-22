import 'package:axis_app/screens/my/my_page_screen.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:axis_app/widgets/status_bar_blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('실제 앱(상단 여백 있음)에서는 상태바 자리에 그라데이션을 깔고 내용은 그 아래부터 시작한다', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const MyPageScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.descendant(of: find.byType(StatusBarBlur), matching: find.byType(DecoratedBox)), findsOneWidget);
    expect(tester.getTopLeft(find.text('수현 님')).dy, greaterThan(47));
  });

  testWidgets('테스트 링크(상단 여백 0)에서는 블러를 그리지 않는다', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const MyPageScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.descendant(of: find.byType(StatusBarBlur), matching: find.byType(DecoratedBox)), findsNothing);
  });
}
