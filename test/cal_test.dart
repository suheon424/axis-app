import 'package:axis_app/screens/main/achievement_screen.dart';
import 'package:axis_app/screens/main/add_schedule_screen.dart';
import 'package:axis_app/screens/main/cal_data.dart';
import 'package:axis_app/screens/main/cal_widgets.dart';
import 'package:axis_app/screens/main/calendar_screen.dart';
import 'package:axis_app/screens/main/schedule_list_screen.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:axis_app/widgets/kit/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

/// 캘린더를 띄우는 첫 화면(뒤로가기 확인용).
class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CalendarScreen())),
        child: const Text('열기'),
      ),
    ),
  );
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
    CalendarScreen.coachmarkDismissed = false;
  });

  testWidgets('디자인의 2026년 11월을 보여 주고 달을 넘긴다', (tester) async {
    await tester.pumpWidget(_app(const CalendarScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('2026년 11월'), findsOneWidget);
    expect(find.text('수현 님'), findsOneWidget);
    expect(find.text('달성률이 높아졌어요. 잘하고 있어요!'), findsOneWidget);
    expect(find.text('계획 진척도 확인하기'), findsOneWidget);
    expect(find.byType(CalDayCell), findsNWidgets(30));
    expect(tester.takeException(), isNull);

    // 다음 달은 아직 오지 않아 막혀 있다.
    await tester.tap(find.bySemanticsLabel('다음 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 11월'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('이전 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 10월'), findsOneWidget);
    expect(find.byType(CalDayCell), findsNWidgets(31));

    await tester.tap(find.bySemanticsLabel('다음 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 11월'), findsOneWidget);
  });

  testWidgets('날짜를 누르면 일정 목록, 카드는 달성률, +는 일정 추가, 뒤로는 닫힌다', (tester) async {
    await tester.pumpWidget(_app(const _Launcher()));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('^11월 18일')));
    await tester.pumpAndSettle();
    expect(find.byType(ScheduleListScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(ScheduleListScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('계획 진척도 확인하기'));
    await tester.pumpAndSettle();
    expect(find.byType(AchievementScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(AchievementScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('일정 추가'));
    await tester.pumpAndSettle();
    expect(find.byType(AddScheduleScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(AddScheduleScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('뒤로'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsNothing);
  });

  testWidgets('날짜를 길게 누르면 그날 미리보기가 뜬다', (tester) async {
    await tester.pumpWidget(_app(const CalendarScreen()));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(tester.getCenter(find.bySemanticsLabel(RegExp('^11월 12일'))));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('11월 12일 (목)'), findsOneWidget);
    expect(find.text('일정 4개 모두 완료'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('11월 12일 (목)'), findsNothing);
  });

  testWidgets('코치마크 v2: 범례를 보여 주고 닫기로 닫힌다', (tester) async {
    await tester.pumpWidget(_app(const CalendarScreen(showCoachmarks: true)));
    await tester.pumpAndSettle();

    expect(find.textContaining('일정은 여기서', findRichText: true), findsOneWidget);
    expect(find.textContaining('하루 실천', findRichText: true), findsOneWidget);
    expect(find.textContaining('은 여기서 확인해요', findRichText: true), findsOneWidget);
    for (final label in ['진행 중', '완료', '시작 전', '일정 없음', '오늘']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect(find.text('시작 전'), findsNothing);
    expect(CalendarScreen.coachmarkDismissed, isFalse);
  });

  testWidgets('코치마크 v2: 다시 보지 않기를 고르면 다음에는 뜨지 않는다', (tester) async {
    await tester.pumpWidget(_app(const CalendarScreen(showCoachmarks: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다시 보지 않기'));
    await tester.pump();
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect(CalendarScreen.coachmarkDismissed, isTrue);

    await tester.pumpWidget(_app(const SizedBox()));
    await tester.pumpWidget(_app(const CalendarScreen(showCoachmarks: true)));
    await tester.pumpAndSettle();
    expect(find.text('다시 보지 않기'), findsNothing);
  });

  test('기록 데이터: 피그마 11월 칸 상태', () {
    expect(CalData.stateFor(DateTime(2026, 11, 1)), AxisDayState.done);
    expect(CalData.stateFor(DateTime(2026, 11, 2)), AxisDayState.inProgress);
    expect(CalData.stateFor(DateTime(2026, 11, 4)), AxisDayState.scheduled);
    expect(CalData.stateFor(DateTime(2026, 11, 11)), AxisDayState.empty);
    expect(CalData.stateFor(DateTime(2026, 11, 24)), AxisDayState.today);
    expect(CalData.recordFor(DateTime(2026, 11, 12))!.done, 4);
  });
}
