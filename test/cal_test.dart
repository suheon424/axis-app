import 'package:axis_app/screens/main/achievement_screen.dart';
import 'package:axis_app/screens/main/cal_data.dart';
import 'package:axis_app/screens/main/cal_widgets.dart';
import 'package:axis_app/screens/main/calendar_screen.dart';
import 'package:axis_app/screens/main/schedule_list_screen.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

/// 캘린더를 띄우는 첫 화면(뒤로가기 확인용).
class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CalendarScreen())),
        child: const Text('열기'),
      ),
    ),
  );
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844) * 3;
    view.devicePixelRatio = 3;
  });

  testWidgets('디자인의 2026년 11월을 보여 주고 달을 넘긴다', (tester) async {
    await tester.pumpWidget(_app(const CalendarScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('2026년 11월'), findsOneWidget);
    expect(find.text('지난달보다 달성률이 높아요. 잘 실천하고 있어요!'), findsOneWidget);
    expect(find.byType(CalDayCell), findsNWidgets(30));
    expect(find.text('계획대로'), findsOneWidget);

    // 다음 달은 아직 오지 않아 막혀 있다.
    await tester.tap(find.bySemanticsLabel('다음 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 11월'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('이전 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 10월'), findsOneWidget);
    expect(find.byType(CalDayCell), findsNWidgets(31));

    await tester.tap(find.bySemanticsLabel('이전 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 9월'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('다음 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 10월'), findsOneWidget);
  });

  testWidgets('날짜를 누르면 일정 목록, 카드는 달성률 화면, 뒤로는 닫힌다', (tester) async {
    await tester.pumpWidget(_app(const _Launcher()));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('^11월 18일')));
    await tester.pumpAndSettle();
    expect(find.byType(ScheduleListScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(ScheduleListScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('이번 달 달성률 확인하기'));
    await tester.pumpAndSettle();
    expect(find.byType(AchievementScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(AchievementScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('뒤로'));
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
    expect(find.text('진행률 100% · 일부 조정'), findsOneWidget);
    expect(find.text('일정 4개 모두 완료'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('11월 12일 (목)'), findsNothing);
  });

  testWidgets('코치마크 1/4~4/4를 차례로 넘기고 닫는다', (tester) async {
    await tester.pumpWidget(_app(const CalendarScreen(showCoachmarks: true)));
    await tester.pumpAndSettle();

    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.text('빨간 점이 있는 날이 오늘이에요'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 4'), findsOneWidget);

    // 어두운 곳을 눌러도 넘어간다.
    await tester.tapAt(const Offset(195, 20));
    await tester.pumpAndSettle();
    expect(find.text('3 / 4'), findsOneWidget);
    expect(find.text('헷갈릴 땐 아래 범례를 보세요'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('4 / 4'), findsOneWidget);
    expect(find.text('11월 12일 (목)'), findsOneWidget);

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('4 / 4'), findsNothing);
    expect(find.text('2026년 11월'), findsOneWidget);
  });

  testWidgets('코치마크는 건너뛰기로 바로 닫힌다', (tester) async {
    await tester.pumpWidget(_app(const CalendarScreen(showCoachmarks: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('건너뛰기'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 4'), findsNothing);
  });

  test('기록 데이터: 오늘 이후는 비어 있고 11월 12일은 100% 일부 조정', () {
    expect(CalData.recordFor(DateTime(2026, 11, 24)), isNull);
    final r = CalData.recordFor(DateTime(2026, 11, 12))!;
    expect(r.percent, 100);
    expect(r.mark, CalMark.adjust);
  });
}
