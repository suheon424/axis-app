import 'package:axis_app/main.dart';
import 'package:axis_app/screens/address_detail_screen.dart';
import 'package:axis_app/screens/address_search_screen.dart';
import 'package:axis_app/screens/character_screen.dart';
import 'package:axis_app/screens/home_screen.dart';
import 'package:axis_app/screens/login_screen.dart';
import 'package:axis_app/screens/profile_setup_screen.dart';
import 'package:axis_app/screens/signup_screen.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: screen));
  await tester.pumpAndSettle();
}

/// 01 → 02 로그인.
Future<void> _openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const AxisApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('로그인'));
  await tester.pumpAndSettle();
  expect(find.byType(LoginScreen), findsOneWidget);
}

void main() {
  // 실제 글꼴(Pretendard)로 배치해야 앱과 같은 폭이 나온다.
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

  testWidgets('01 시작 화면의 로그인과 이메일로 로그인하기는 02 로그인으로 가고 뒤로 돌아온다', (tester) async {
    await _openLogin(tester);
    expect(find.text('axis 플래너와 함께\n계획을 완성할 준비 되셨나요?'), findsOneWidget);

    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsNothing);

    await tester.tap(find.text('이메일로 로그인하기'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('로그인 실패면 비밀번호 칸에 오류가 뜨고, 고쳐서 로그인하면 05 온보딩으로 간다', (tester) async {
    await _openLogin(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'suhyun424@hansung.ac.kr');
    await tester.enterText(fields.at(1), '12');
    await tester.pump();
    await tester.tap(find.text('로그인').last);
    await tester.pumpAndSettle();
    expect(find.text(loginFailedMessage), findsOneWidget);
    expect(find.byType(ProfileSetupScreen), findsNothing);

    await tester.enterText(fields.at(1), '12345678');
    await tester.pump();
    expect(find.text(loginFailedMessage), findsNothing);
    await tester.tap(find.text('로그인').last);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.text('반가워요 suhyun424 님!'), findsOneWidget);
  });

  testWidgets('회원가입 후 MBTI를 고르고 캐릭터 화면을 거쳐 홈으로 간다', (tester) async {
    await _openLogin(tester);
    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '수현');
    await tester.enterText(fields.at(1), 'suhyun@example.com');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret1');
    await tester.tap(find.text('[필수] 서비스 이용약관 동의'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.text('반가워요 수현 님!'), findsOneWidget);

    await tester.tap(find.text('MBTI').last);
    await tester.pumpAndSettle();
    expect(find.text('아직 선택하지 않았어요'), findsOneWidget);
    for (final letter in ['E', 'N', 'F', 'P']) {
      await tester.tap(find.text(letter).first);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('ENFP'), findsOneWidget);
    await tester.tap(find.text('선택 완료'));
    await tester.pumpAndSettle();
    expect(find.text('ENFP'), findsOneWidget);

    await tester.tap(find.text('나중에 입력할게요'));
    await tester.pumpAndSettle();
    expect(find.byType(CharacterScreen), findsOneWidget);
    expect(find.text('수현 님'), findsOneWidget);

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('회원가입 오류: 이메일 형식과 비밀번호 확인이 틀리면 칸 아래에 알리고 버튼이 비활성', (tester) async {
    await _pumpScreen(tester, const SignupScreen());
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '수현');
    await tester.enterText(fields.at(1), 'suhyun424@hansung');
    await tester.enterText(fields.at(2), 'secret12');
    await tester.enterText(fields.at(3), 'secre');
    await tester.tap(find.text('전체 동의'));
    await tester.tap(find.text('만나서 반가워요'));
    await tester.pumpAndSettle();
    expect(find.text('이메일 형식을 확인해 주세요.'), findsOneWidget);
    expect(find.text('비밀번호가 서로 달라요.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSetupScreen), findsNothing);
  });

  testWidgets('회원가입에서 빈 칸으로 누르면 테스트 값이 채워져 넘어간다', (tester) async {
    await _pumpScreen(tester, const SignupScreen());
    await tester.tap(find.text('가입하기'));
    await tester.pump();
    expect(find.text('h4s2h4@hansung.ac.kr'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.text('반가워요 수현 님!'), findsOneWidget);
  });

  testWidgets('05 온보딩: 준비시간을 고르고 세 칸을 다 채우면 다음이 활성화되어 06으로 간다', (tester) async {
    await _pumpScreen(tester, const ProfileSetupScreen(nickname: '수현'));
    expect(find.text('나중에 입력할게요'), findsOneWidget);

    await tester.tap(find.text('평소 준비시간').last);
    await tester.pumpAndSettle();
    expect(find.text('준비 시간을 반영해 출발 시간을 알려 드려요.'), findsOneWidget);
    expect(find.text('40분'), findsWidgets);
    await tester.tap(find.text('60분'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('늘리기'));
    await tester.pump();
    expect(find.text('70분'), findsOneWidget);
    await tester.tap(find.text('선택 완료'));
    await tester.pumpAndSettle();
    expect(find.text('70분'), findsOneWidget);

    await tester.tap(find.text('MBTI').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('잘 모르겠어요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('집 주소').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '한성대');
    await tester.pumpAndSettle();
    await tester.tap(find.text('한성대학교', findRichText: true).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.text('나중에 입력할게요'), findsNothing);
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.byType(CharacterScreen), findsOneWidget);
  });

  testWidgets('주소 검색에서 고르고 상세 주소를 붙여 돌려준다', (tester) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
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
    expect(find.text('이렇게 검색해 보세요'), findsOneWidget);
    expect(find.text('내 위치'), findsOneWidget);

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
    expect(find.byType(AddressDetailScreen), findsOneWidget);
    expect(find.text('주소 다시 검색'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '3층');
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    expect(picked, '서울 성북구 삼선교로16길 116, 3층');
  });

  testWidgets('06 캐릭터: 배경색과 캐릭터를 고르고 다음에 설정하기로도 홈에 간다', (tester) async {
    await _pumpScreen(tester, const CharacterScreen(nickname: '수현'));
    expect(find.text('모든 준비가 완료되었어요!'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('배경색 파랑'));
    await tester.tap(find.bySemanticsLabel('캐릭터 1'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('다음에 설정하기'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
