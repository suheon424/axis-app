import 'package:axis_app/screens/main/add_schedule_screen.dart';
import 'package:axis_app/screens/main/calendar_screen.dart';
import 'package:axis_app/screens/main/list_ai.dart';
import 'package:axis_app/screens/main/list_sheets.dart';
import 'package:axis_app/screens/main/map_screen.dart';
import 'package:axis_app/screens/main/schedule_list_screen.dart';
import 'package:axis_app/widgets/kit/kit.dart';
import 'package:axis_app/screens/badge/badge_celebration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpList(WidgetTester tester, {bool jMode = false, bool empty = false}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: ScheduleListScreen(initialJMode: jMode, empty: empty),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// 반복 애니메이션(AI 오브·도는 고리)이 있을 때 pumpAndSettle 대신 일정 시간만 흘린다.
Future<void> settle(WidgetTester tester, [int ms = 600]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> startAi(WidgetTester tester) async {
  await tester.ensureVisible(find.text('틀어진 일정 맞추기'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('틀어진 일정 맞추기'));
}

/// 떠 있는 토스트의 타이머를 흘려보낸다.
Future<void> flushToast(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
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

  testWidgets('목록: 체크박스로 완료를 바꾸고, 6개를 모두 체크하면 배지 팝업이 뜬다', (tester) async {
    await pumpList(tester);
    expect(find.text('11월 23일 월요일'), findsOneWidget);
    expect(find.text('일정 6개'), findsOneWidget);
    expect(find.byType(BadgeCelebration), findsNothing);

    for (final title in ['팀 점심', '고객사 미팅', '러닝 5km']) {
      await tapVisible(tester, find.bySemanticsLabel('$title 완료'));
    }
    expect(find.byType(BadgeCelebration), findsNothing);

    await tapVisible(tester, find.bySemanticsLabel('관리비 납부 완료'));
    expect(find.byType(BadgeCelebration), findsOneWidget);

    expect(find.textContaining('각성의 순간', findRichText: true), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('닫기').last);
    await tester.pumpAndSettle();
    expect(find.byType(BadgeCelebration), findsNothing);
  });

  testWidgets('빈 상태: 일정이 없는 날은 안내와 일정 추가하기 버튼을 보여 준다', (tester) async {
    await pumpList(tester);
    await tester.tap(find.bySemanticsLabel('11월 24일 화요일'));
    await tester.pumpAndSettle();
    expect(find.text('일정 0개'), findsOneWidget);
    expect(find.text('이날은 아직 일정이 없어요'), findsOneWidget);
    expect(find.text('틀어진 일정 맞추기'), findsNothing);

    await tapVisible(tester, find.text('일정 추가하기'));
    expect(find.byType(AddScheduleScreen), findsOneWidget);
    expect(find.text('11월 24일 (화)'), findsOneWidget);
  });

  testWidgets('월 머리글(2026년 11월)은 이제 캘린더를 열지 않는다', (tester) async {
    await pumpList(tester);
    expect(find.bySemanticsLabel('2026년 11월 달력 보기'), findsNothing);
    await tester.tap(find.text('2026년 11월'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsNothing);
  });

  testWidgets('J모드: 시간·AI 꼬리표를 보고 제안을 펼친다', (tester) async {
    await pumpList(tester);
    expect(find.text('08:30 AM'), findsNothing);

    await tester.tap(find.text('J모드'));
    await tester.pumpAndSettle();
    expect(find.text('08:30 AM'), findsOneWidget);
    expect(find.text('Pace'), findsOneWidget);
    expect(find.text('10분 일찍 알림 받기'), findsNothing);

    await tester.tap(find.text('Pace'));
    await tester.pumpAndSettle();
    expect(find.text('10분 일찍 알림 받기'), findsOneWidget);
    await tester.tap(find.text('Plan B'));
    await tester.pumpAndSettle();
    expect(find.text('플랜 B로 바꾸기'), findsOneWidget);

    await tester.tap(find.text('괜찮아요'));
    await tester.pumpAndSettle();
    expect(find.text('10분 일찍 알림 받기'), findsNothing);

    await tester.tap(find.text('J모드'));
    await tester.pumpAndSettle();
    expect(find.text('08:30 AM'), findsNothing);
  });

  testWidgets('상세 시트 → 더보기 → 삭제 확인으로 일정을 지운다', (tester) async {
    await pumpList(tester);

    await tapVisible(tester, find.text('회사 출근'));
    expect(find.byType(ListDetailSheet), findsOneWidget);
    expect(find.text('08:30 – 09:00 AM'), findsOneWidget);
    expect(find.text('일정 수정'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('더보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('일정을 삭제할까요?'), findsOneWidget);
    expect(find.text('이후 일정 삭제'), findsOneWidget);

    await tester.tap(find.text('이 일정만 삭제'));
    await tester.pumpAndSettle();
    expect(find.text('회사 출근'), findsNothing);
    expect(find.text('일정 5개'), findsOneWidget);
    await flushToast(tester);
  });

  testWidgets('상세 시트의 일정 수정은 수정 화면을 연다', (tester) async {
    await pumpList(tester);
    await tapVisible(tester, find.text('팀 점심'));
    await tester.tap(find.text('일정 수정'));
    await tester.pumpAndSettle();
    expect(find.byType(AddScheduleScreen), findsOneWidget);
    expect(find.text('팀 점심'), findsOneWidget);
  });

  testWidgets('일정을 왼쪽으로 밀면 이동·삭제가 드러나고, 닫으면 그대로 남는다', (tester) async {
    await pumpList(tester, jMode: true);
    final row = find.text('러닝 5km');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.drag(row, const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('이동'), findsOneWidget);

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('일정을 삭제할까요?'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('닫기').last);
    await tester.pumpAndSettle();
    expect(find.text('러닝 5km'), findsOneWidget);
    expect(find.text('일정 6개'), findsOneWidget);
  });

  testWidgets('틀어진 일정 맞추기 → 분석 중 → 제안대로 맞추기 → J모드 + 완료 토스트', (tester) async {
    await pumpList(tester);

    await startAi(tester);
    await settle(tester, 300);
    expect(find.byType(ListAiAnalyzing), findsOneWidget);
    expect(find.text('틀어진 일정을 다시 맞추고 있어요'), findsOneWidget);
    expect(find.text('남은 일정 4개 다시 배치'), findsOneWidget);

    await settle(tester, 3500);
    expect(find.byType(ListAiAnalyzing), findsNothing);
    expect(find.byType(ListAiSuggestionScreen), findsOneWidget);
    expect(find.text('23일(월) 바뀐 일정 미리보기'), findsOneWidget);
    expect(find.textContaining('만 미루면 다 지킬 수 있어요', findRichText: true), findsOneWidget);

    await tester.tap(find.text('제안대로 맞추기'));
    await tester.pumpAndSettle();
    expect(find.byType(ListAiSuggestionScreen), findsNothing);
    expect(find.text('남은 일정 4개를 다시 맞췄어요'), findsOneWidget);
    expect(find.text('01:00 PM'), findsOneWidget);
    expect(find.text('02:35 PM'), findsOneWidget);
    await flushToast(tester);
    expect(find.text('남은 일정 4개를 다시 맞췄어요'), findsNothing);
  });

  testWidgets('AI 제안을 닫으면 일정은 그대로다', (tester) async {
    await pumpList(tester);
    await startAi(tester);
    await settle(tester, 3800);
    expect(find.byType(ListAiSuggestionScreen), findsOneWidget);
    await tester.tap(find.text('그대로 둘게요'));
    await tester.pumpAndSettle();
    expect(find.byType(ListAiSuggestionScreen), findsNothing);
    expect(find.text('01:00 PM'), findsNothing);
  });

  testWidgets('AI 분석 중 맞추기 취소하면 목록으로 돌아온다', (tester) async {
    await pumpList(tester);
    await startAi(tester);
    await settle(tester, 300);
    await tester.tap(find.text('맞추기 취소'));
    await settle(tester, 600);
    expect(find.byType(ListAiAnalyzing), findsNothing);
    expect(find.byType(ListAiSuggestionScreen), findsNothing);
  });

  testWidgets('일정 추가: 제목을 넣어야 저장하기가 켜진다', (tester) async {
    await pumpList(tester);
    await tester.tap(find.bySemanticsLabel('일정 추가'));
    await tester.pumpAndSettle();
    expect(find.byType(AddScheduleScreen), findsOneWidget);
    expect(find.text('09:00 – 10:00 AM'), findsOneWidget);
    expect(tester.widget<AxisCtaButton>(find.byType(AxisCtaButton)).enabled, isFalse);

    await tester.enterText(find.byType(TextField).first, '팀 회의');
    await tester.pumpAndSettle();
    expect(tester.widget<AxisCtaButton>(find.byType(AxisCtaButton)).enabled, isTrue);
    await tester.tap(find.text('저장하기'));
    await tester.pumpAndSettle();
    expect(find.byType(AddScheduleScreen), findsNothing);
  });

  testWidgets('지도 탭을 누르면 같은 화면에서 지도 탭으로 바뀐다', (tester) async {
    await pumpList(tester);
    await tester.tap(find.text('지도'));
    await settle(tester);
    expect(find.byType(MapTab), findsOneWidget);
    expect(find.byType(ScheduleListScreen), findsOneWidget);
    await tester.tap(find.text('목록'));
    await settle(tester);
    expect(find.byType(MapTab), findsNothing);
  });
}
