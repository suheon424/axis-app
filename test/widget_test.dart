import 'package:axis_app/main.dart';
import 'package:axis_app/screens/login_screen.dart';
import 'package:axis_app/screens/profile_setup_screen.dart';
import 'package:axis_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844) * 3;
    view.devicePixelRatio = 3;
  });

  testWidgets('첫 화면에서 이메일 로그인으로 이동하고 뒤로 돌아온다', (tester) async {
    await tester.pumpWidget(const AxisApp());
    await tester.pumpAndSettle();
    expect(find.text('가입하기'), findsOneWidget);

    await tester.tap(find.text('이메일로 로그인 하기'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('회원가입 후 추가 정보에서 MBTI를 고른다', (tester) async {
    await tester.pumpWidget(const AxisApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '수현');
    await tester.enterText(fields.at(1), 'suhyun@example.com');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret1');
    await tester.tap(find.text('회원가입 하기'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.text('반가워요 수현님!'), findsOneWidget);

    await tester.tap(find.text('mbti 성향을 입력해주세요.').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENFP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작하기').last);
    await tester.pumpAndSettle();
    expect(find.text('ENFP'), findsOneWidget);
  });
}
