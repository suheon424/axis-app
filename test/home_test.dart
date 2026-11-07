import 'package:axis_app/screens/home_screen.dart';
import 'package:axis_app/screens/main/achievement_screen.dart';
import 'package:axis_app/screens/main/add_schedule_screen.dart';
import 'package:axis_app/screens/main/calendar_screen.dart';
import 'package:axis_app/screens/main/home_spline_cube.dart';
import 'package:axis_app/screens/main/schedule_list_screen.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

double _fingerOpacity(WidgetTester tester) => tester.widget<AnimatedOpacity>(find.byKey(SplineCube.fingerKey)).opacity;

/// 깜빡이는 로딩 막대가 있어도 끝나도록 일정 시간만 흘려보낸다.
Future<void> _settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
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

  testWidgets('홈: 잠깐 로딩한 뒤 오늘의 실천과 이번 달 실천 목록을 보여 준다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(nickname: '테스트')));
    await tester.pump();
    expect(find.text('Todo'), findsNothing);
    expect(find.text('이번 달 실천'), findsOneWidget);

    await tester.pump(HomeScreen.loadingDuration);
    await tester.pumpAndSettle();
    for (final name in ['Todo', 'Routine', 'Study', 'Travel', 'Expenses', 'Workout']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('30일 중 18일 실천'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('13%'), findsOneWidget);
    expect(find.textContaining('4개 남음', findRichText: true), findsOneWidget);
    expect(find.textContaining('33%', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈: "다음" 일정을 누르면 한 칸 실천한다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(initialState: HomeLoadState.ready)));
    await tester.pumpAndSettle();

    expect(find.text('12:30 PM 팀 점심'), findsOneWidget);
    await tester.tap(find.text('12:30 PM 팀 점심'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3개 남음', findRichText: true), findsOneWidget);
    expect(find.text('03:00 PM 영어 공부'), findsOneWidget);
  });

  testWidgets('홈: 카테고리 줄을 누르면 일정 목록(J모드)으로 간다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(initialState: HomeLoadState.ready)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    expect(find.byType(ScheduleListScreen), findsOneWidget);
  });

  testWidgets('홈: + 버튼은 일정 추가 화면을 연다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(initialState: HomeLoadState.ready)));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('일정 추가'));
    await tester.pumpAndSettle();
    expect(find.byType(AddScheduleScreen), findsOneWidget);
  });

  testWidgets('홈: 네트워크 오류에서 다시 시도하면 로딩 뒤 목록이 뜬다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(initialState: HomeLoadState.error)));
    await tester.pumpAndSettle();
    expect(find.text('인터넷 연결이 불안정해요'), findsOneWidget);
    expect(find.text('이번 달 실천'), findsNothing);

    await tester.tap(find.text('다시 시도'));
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('인터넷 연결이 불안정해요'), findsNothing);
    expect(find.text('Todo'), findsOneWidget);
  });

  testWidgets('홈: 알림 권한 요청 대화상자(허용하기·나중에)', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(askNotificationPermission: true)));
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('알림을 켜 둘까요?'), findsOneWidget);
    expect(find.text('나중에'), findsOneWidget);

    await tester.tap(find.text('허용하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('알림을 켜 둘까요?'), findsNothing);
    expect(find.text('알림을 켰어요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('홈: 로고를 길게 누르면 데모 상태를 고를 수 있다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(initialState: HomeLoadState.ready)));
    await tester.pumpAndSettle();

    await tester.longPress(find.bySemanticsLabel('axis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('네트워크 오류'));
    await tester.pumpAndSettle();
    expect(find.text('인터넷 연결이 불안정해요'), findsOneWidget);
  });

  testWidgets('토글: 목록 ↔ 달성률을 제자리에서 바꾼다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(initialState: HomeLoadState.ready)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('달성률'));
    await tester.pumpAndSettle();
    expect(find.byType(AchievementScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.text('6/27'), findsOneWidget);
    expect(find.text('남은 일정 보기'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('목록'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AchievementScreen), findsNothing);
    expect(find.text('Todo'), findsOneWidget);
  });

  testWidgets('달성률: 남은 일정 보기는 캘린더(코치마크)를 연다', (tester) async {
    CalendarScreen.coachmarkDismissed = false;
    await tester.pumpWidget(_app(const AchievementScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('남은 일정 보기'));
    await tester.pumpAndSettle();
    final cal = tester.widget<CalendarScreen>(find.byType(CalendarScreen));
    expect(cal.showCoachmarks, isTrue);
  });

  testWidgets('달성률: 큐브를 누르는 동안 손가락 버튼이 사라졌다가 떼면 다시 보인다', (tester) async {
    await tester.pumpWidget(_app(const AchievementScreen()));
    await tester.pumpAndSettle();

    // 테스트 환경(데스크톱)에서는 장면 대신 피그마 큐브 그림이 보인다.
    expect(find.byKey(SplineCube.imageKey), findsOneWidget);
    expect(find.byKey(SplineCube.sceneKey), findsNothing);
    expect(_fingerOpacity(tester), 1);

    final gesture = await tester.startGesture(tester.getCenter(find.byKey(SplineCube.imageKey)));
    await tester.pumpAndSettle();
    expect(_fingerOpacity(tester), 0);

    await gesture.moveBy(const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(_fingerOpacity(tester), 0);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_fingerOpacity(tester), 1);
  });

  testWidgets('SplineCube: 주소가 비면 그림만 보인다', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(body: SplineCube(url: ''))));
    expect(find.byKey(SplineCube.imageKey), findsOneWidget);
    expect(find.byKey(SplineCube.sceneKey), findsNothing);
  });
}
