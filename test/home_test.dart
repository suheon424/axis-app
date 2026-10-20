import 'package:axis_app/screens/home_screen.dart';
import 'package:axis_app/screens/main/achievement_screen.dart';
import 'package:axis_app/screens/main/add_schedule_screen.dart';
import 'package:axis_app/screens/main/calendar_screen.dart';
import 'package:axis_app/screens/main/home_rubiks_cube.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

double _fingerOpacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byKey(RubiksCube.fingerKey)).opacity;

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844) * 3;
    view.devicePixelRatio = 3;
  });

  testWidgets('홈: 카드가 보이고, 다음 일정 버튼으로 한 칸 실천한다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(nickname: '테스트')));
    await tester.pumpAndSettle();

    expect(find.text('Todo'), findsOneWidget);
    expect(find.textContaining('4개 남음', findRichText: true), findsOneWidget);
    expect(find.text('PM 12:30 팀 점심'), findsOneWidget);

    await tester.tap(find.text('PM 12:30 팀 점심'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3개 남음', findRichText: true), findsOneWidget);
    expect(find.text('PM 03:00 영어 공부'), findsOneWidget);
  });

  testWidgets('홈: 카테고리 카드를 누르면 캘린더(코치마크)로 간다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(nickname: '테스트')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Todo'));
    await tester.pumpAndSettle();
    final cal = tester.widget<CalendarScreen>(find.byType(CalendarScreen));
    expect(cal.showCoachmarks, isTrue);
  });

  testWidgets('홈: + 버튼으로 일정 추가, 제목을 넣어야 추가된다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(nickname: '테스트')));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('일정 추가'));
    await tester.pumpAndSettle();
    expect(find.byType(AddScheduleScreen), findsOneWidget);
    expect(find.text('반복 안 함'), findsOneWidget);

    // 제목 없이 누르면 그대로.
    await tester.tap(find.text('일정 추가하기'));
    await tester.pumpAndSettle();
    expect(find.byType(AddScheduleScreen), findsOneWidget);

    // 반복 시트에서 고르기.
    await tester.tap(find.text('반복 안 함'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('매주'));
    await tester.pumpAndSettle();
    expect(find.text('매주'), findsOneWidget);

    // 상세 설정 펼치기.
    await tester.tap(find.text('상세 설정'));
    await tester.pumpAndSettle();
    expect(find.text('위치'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '팀 회의');
    await tester.pumpAndSettle();
    await tester.tap(find.text('일정 추가하기'));
    await tester.pumpAndSettle();
    expect(find.byType(AddScheduleScreen), findsNothing);
    expect(find.text('"팀 회의" 일정을 추가했어요.'), findsOneWidget);
  });

  testWidgets('토글: 목록 ↔ 달성률을 제자리에서 바꾼다', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen(nickname: '테스트')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('달성률'));
    await tester.pump();
    expect(find.byType(AchievementScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.text('6/27'), findsOneWidget);
    expect(find.text('남은 일정 보기'), findsOneWidget);

    await tester.tap(find.text('목록'));
    await tester.pump();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AchievementScreen), findsNothing);
  });

  testWidgets('달성률: 큐브를 누르는 동안 손가락 버튼이 사라졌다가 떼면 다시 보인다', (tester) async {
    await tester.pumpWidget(_app(const AchievementScreen()));
    await tester.pumpAndSettle();

    expect(find.byKey(RubiksCube.cubeKey), findsOneWidget);
    expect(_fingerOpacity(tester), 1);

    final gesture = await tester.startGesture(tester.getCenter(find.byKey(RubiksCube.cubeKey)));
    await tester.pumpAndSettle();
    expect(_fingerOpacity(tester), 0);

    await gesture.moveBy(const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(_fingerOpacity(tester), 0);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_fingerOpacity(tester), 1);
  });
}
