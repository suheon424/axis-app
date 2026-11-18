import 'package:axis_app/screens/my/inquiry_screen.dart';
import 'package:axis_app/screens/my/my_comments_screen.dart';
import 'package:axis_app/screens/my/my_data.dart';
import 'package:axis_app/screens/my/my_page_screen.dart';
import 'package:axis_app/screens/my/my_posts_screen.dart';
import 'package:axis_app/screens/my/notice_screen.dart';
import 'package:axis_app/screens/my/notification_settings_screen.dart';
import 'package:axis_app/screens/my/point_history_screen.dart';
import 'package:axis_app/screens/my/profile_edit_screen.dart';
import 'package:axis_app/screens/my/saved_templates_screen.dart';
import 'package:axis_app/screens/my/version_info_screen.dart';
import 'package:axis_app/screens/my/withdraw_screen.dart';
import 'package:axis_app/screens/welcome_screen.dart';
import 'package:axis_app/widgets/kit/kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: KeyedSubtree(key: UniqueKey(), child: screen),
    ),
  );
  await _settle(tester);
}

/// 토스트 타이머·전환 애니메이션이 있어 일정 시간만 흘린다.
Future<void> _settle(WidgetTester tester, [int ms = 800]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await _settle(tester);
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
    myProfile.value = const MyProfile(
      nickname: '황수현',
      callName: '수현',
      intro: '계획은 작게, 실행은 꾸준히',
      character: 5,
      points: 1550,
    );
    MyPageScreen.openBadges = null;
  });

  tearDown(hideAxisToast);

  testWidgets('마이 첫 화면은 프로필·포인트·메뉴를 보여 주고 각 화면으로 이동한다', (tester) async {
    await _pump(tester, const MyPageScreen());
    expect(find.text('수현 님'), findsOneWidget);
    expect(find.text('1,550P'), findsOneWidget);
    expect(find.text('11.23.0'), findsOneWidget);
    expect(find.byType(AxisTabBar), findsOneWidget);

    final screens = <String, Type>{
      '보유 포인트': PointHistoryScreen,
      '내 정보 수정': ProfileEditScreen,
      '내가 쓴 게시물': MyPostsScreen,
      '내가 쓴 댓글': MyCommentsScreen,
      '저장한 템플릿': SavedTemplatesScreen,
      '공지사항': NoticeScreen,
      '알림 설정': NotificationSettingsScreen,
      '1:1 문의': InquiryScreen,
      '버전 정보': VersionInfoScreen,
      '탈퇴하기': WithdrawScreen,
    };
    for (final e in screens.entries) {
      await _tap(tester, find.text(e.key).first);
      expect(find.byType(e.value), findsOneWidget, reason: e.key);
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.byType(e.value))).pop();
      await _settle(tester);
    }
  });

  testWidgets('배지 보관함은 등록된 화면을 열고, 없으면 준비 중 안내를 띄운다', (tester) async {
    await _pump(tester, const MyPageScreen());
    await _tap(tester, find.text('배지 보관함'));
    expect(find.text('배지 보관함은 준비 중이에요.'), findsOneWidget);
    hideAxisToast();

    MyPageScreen.openBadges = (_) => const Scaffold(body: Text('배지 화면'));
    await _tap(tester, find.text('배지 보관함'));
    expect(find.text('배지 화면'), findsOneWidget);
  });

  testWidgets('로그아웃을 확인하면 첫 화면으로 돌아간다', (tester) async {
    await _pump(tester, const MyPageScreen());
    await _tap(tester, find.text('로그아웃'));
    expect(find.text('로그아웃할까요?'), findsOneWidget);
    await _tap(tester, find.text('취소'));
    expect(find.byType(MyPageScreen), findsOneWidget);

    await _tap(tester, find.text('로그아웃'));
    await tester.tap(find.text('로그아웃').last);
    await _settle(tester, 1500);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(MyPageScreen), findsNothing);
  });

  testWidgets('프로필을 저장하면 토스트가 뜨고 마이 화면 이름이 바뀐다', (tester) async {
    await _pump(tester, const MyPageScreen());
    await _tap(tester, find.text('내 정보 수정'));
    expect(find.text('3/10'), findsOneWidget);
    expect(find.text('suhyun@axis.app'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    final cta = find.widgetWithText(AxisCtaButton, '저장하기');
    expect(tester.widget<AxisCtaButton>(cta).enabled, isFalse);

    await tester.enterText(find.byType(TextField).first, '수수');
    await tester.pump();
    expect(tester.widget<AxisCtaButton>(cta).enabled, isTrue);
    await _tap(tester, cta);
    expect(find.text('프로필을 저장했어요'), findsOneWidget);

    Navigator.of(tester.element(find.byType(ProfileEditScreen))).pop();
    await _settle(tester);
    expect(find.text('수수 님'), findsOneWidget);
    hideAxisToast();
  });

  testWidgets('포인트 내역은 적립·사용으로 거르고, 비면 빈 상태를 보여 준다', (tester) async {
    await _pump(tester, const PointHistoryScreen());
    expect(find.text('2026.11.23 (월)'), findsOneWidget);
    expect(find.text('-500P'), findsOneWidget);
    await _tap(tester, find.text('사용'));
    expect(find.text('+10P'), findsNothing);
    expect(find.text('-500P'), findsOneWidget);

    await _pump(tester, const PointHistoryScreen(entries: []));
    expect(find.text('0P'), findsOneWidget);
    expect(find.text('아직 포인트 내역이 없어요'), findsOneWidget);
    expect(find.text('이벤트 보러 가기'), findsOneWidget);
  });

  testWidgets('게시물을 모두 삭제하면 빈 상태가 된다', (tester) async {
    await _pump(tester, MyPostsScreen(posts: [sampleMyPosts.first]));
    expect(find.text('한강 러닝 5km 4주 플랜'), findsOneWidget);
    await _tap(tester, find.byWidgetPredicate((w) => w is AxisIconButton && w.tooltip == '더보기'));
    await _tap(tester, find.text('삭제하기'));
    await _tap(tester, find.text('삭제'));
    expect(find.text('아직 작성한 게시물이 없어요'), findsOneWidget);
    expect(find.text('첫 게시물 쓰기'), findsOneWidget);
    hideAxisToast();
  });

  testWidgets('댓글·저장한 템플릿 빈 상태', (tester) async {
    await _pump(tester, const MyCommentsScreen(comments: []));
    expect(find.text('아직 남긴 댓글이 없어요'), findsOneWidget);
    await _pump(tester, const MyCommentsScreen());
    expect(find.text('비전공생의 CPA 공부 계획'), findsNWidgets(2));

    await _pump(tester, SavedTemplatesScreen(templates: [sampleSavedTemplates.first]));
    await _tap(tester, find.bySemanticsLabel('저장 취소'));
    expect(find.text('아직 저장한 템플릿이 없어요'), findsOneWidget);
    hideAxisToast();
  });

  testWidgets('공지를 누르면 본문이 열린다', (tester) async {
    await _pump(tester, const NoticeScreen());
    expect(find.text('N'), findsOneWidget);
    await _tap(tester, find.text('친구 초대 이벤트가 시작됐어요'));
    expect(find.byType(MyDocumentScreen), findsOneWidget);
  });

  testWidgets('전체 알림을 끄면 모든 알림이 꺼진다', (tester) async {
    await _pump(tester, const NotificationSettingsScreen());
    bool on(String t) => tester.widget<AxisSettingRow>(find.widgetWithText(AxisSettingRow, t)).value!;
    expect(on('일정 시작 전 알림'), isTrue);
    await _tap(tester, find.text('전체 알림'));
    expect(on('일정 시작 전 알림'), isFalse);
    expect(on('내 게시물 댓글'), isFalse);
    expect(on('전체 알림'), isFalse);
  });

  testWidgets('1:1 문의는 필수 입력 후 보낼 수 있고 문의 내역에 쌓인다', (tester) async {
    await _pump(tester, const InquiryScreen());
    final cta = find.widgetWithText(AxisCtaButton, '문의 보내기');
    expect(tester.widget<AxisCtaButton>(cta).enabled, isFalse);

    await _tap(tester, find.text('유형을 선택해 주세요'));
    await _tap(tester, find.text('이벤트 · 포인트'));
    await tester.enterText(find.byType(TextField).at(0), '친구 초대 포인트가 들어오지 않았어요');
    await tester.enterText(find.byType(TextField).at(1), '친구가 제 초대 코드로 가입했는데 포인트가 없어요.');
    await tester.pump();
    expect(find.text('28/1000'), findsOneWidget);
    expect(tester.widget<AxisCtaButton>(cta).enabled, isTrue);

    await _tap(tester, cta);
    expect(find.text('친구 초대 포인트가 들어오지 않았어요'), findsOneWidget);
    expect(find.text('답변 대기'), findsOneWidget);
    hideAxisToast();
  });

  testWidgets('탈퇴는 이유와 확인 체크 후에만 되고 첫 화면으로 돌아간다', (tester) async {
    await _pump(tester, const WithdrawScreen());
    expect(find.text('수현 님, 정말 떠나시나요?'), findsOneWidget);
    expect(find.text('1,550P'), findsOneWidget);

    await _tap(tester, find.text('알림이 너무 많아요'));
    expect(find.text('알림 설정 바로가기'), findsOneWidget);
    await _tap(tester, find.text('탈퇴하기').last);
    expect(find.byType(WithdrawScreen), findsOneWidget);

    await _tap(tester, find.text('위 내용을 모두 확인했어요'));
    await _tap(tester, find.text('탈퇴하기').last);
    await _settle(tester, 1500);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
