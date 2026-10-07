import 'package:axis_app/main.dart';
import 'package:axis_app/screens/address_search_screen.dart';
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

  testWidgets('회원가입에서 빈 칸으로 누르면 테스트 값이 채워져 넘어간다', (tester) async {
    await tester.pumpWidget(const AxisApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('회원가입 하기'));
    await tester.pump();
    expect(find.text('h4s2h4@hansung.ac.kr'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.text('반가워요 수현님!'), findsOneWidget);
  });

  testWidgets('위치 찾기에서 입력하면 관련 주소가 뜨고 고르면 돌려준다', (tester) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await Navigator.of(context)
                  .push<String>(MaterialPageRoute(builder: (_) => const AddressSearchScreen()));
            },
            child: const Text('열기'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '성북');
    await tester.pumpAndSettle();
    expect(find.text('한성대학교', findRichText: true), findsOneWidget);
    expect(find.text('서울역', findRichText: true), findsNothing);

    // 이름이 검색어로 시작하는 성북구청이 주소에만 들어 있는 한성대학교보다 위에 온다.
    final top = tester.getTopLeft(find.text('성북구청', findRichText: true)).dy;
    final lower = tester.getTopLeft(find.text('한성대학교', findRichText: true)).dy;
    expect(top, lessThan(lower));

    await tester.tap(find.text('한성대학교', findRichText: true));
    await tester.pumpAndSettle();
    expect(picked, '서울 성북구 삼선교로16길 116');
  });
}
