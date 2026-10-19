import 'package:axis_app/screens/main/list_ai.dart';
import 'package:axis_app/screens/main/list_sheets.dart';
import 'package:axis_app/screens/main/map_screen.dart';
import 'package:axis_app/screens/main/schedule_list_screen.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpList(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const ScheduleListScreen()));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844) * 3;
    view.devicePixelRatio = 3;
  });

  testWidgets('체크박스로 완료를 바꾸고, 6개를 모두 체크하면 배지 팝업이 뜬다', (tester) async {
    await pumpList(tester);
    expect(find.text('일정 6건'), findsOneWidget);
    expect(find.byType(ListBadgePopup), findsNothing);

    for (final title in ['팀 점심', '고객사 미팅', '러닝 5km']) {
      await tapVisible(tester, find.bySemanticsLabel('$title 완료'));
    }
    expect(find.byType(ListBadgePopup), findsNothing);

    await tapVisible(tester, find.bySemanticsLabel('관리비 납부 완료'));
    expect(find.byType(ListBadgePopup), findsOneWidget);
    expect(find.textContaining('배지를 획득했어요', findRichText: true), findsOneWidget);

    await tester.tap(find.text('이미지 저장'));
    await tester.pump();
    expect(find.text('저장했어요'), findsOneWidget);

    await tester.tap(find.text('칭호로 등록하기'));
    await tester.pumpAndSettle();
    expect(find.byType(ListBadgePopup), findsNothing);
  });

  testWidgets('J모드 칩으로 시간·AI 꼬리표를 보고 제안을 펼친다', (tester) async {
    await pumpList(tester);
    expect(find.text('AM 08:30'), findsNothing);

    await tester.tap(find.text('J모드'));
    await tester.pumpAndSettle();
    expect(find.text('AM 08:30'), findsOneWidget);
    expect(find.text('Pace'), findsOneWidget);
    expect(find.text('10분 일찍 알림 받기'), findsNothing);

    await tester.tap(find.text('Pace'));
    await tester.pumpAndSettle();
    expect(find.text('10분 일찍 알림 받기'), findsOneWidget);

    await tester.tap(find.text('괜찮아요'));
    await tester.pumpAndSettle();
    expect(find.text('Pace'), findsNothing);

    await tester.tap(find.text('J모드'));
    await tester.pumpAndSettle();
    expect(find.text('AM 08:30'), findsNothing);
  });

  testWidgets('일정을 누르면 상세 시트 → 더보기 → 삭제 확인으로 일정을 지운다', (tester) async {
    await pumpList(tester);

    await tapVisible(tester, find.text('회사 출근'));
    expect(find.byType(ListDetailSheet), findsOneWidget);
    expect(find.text('AM 08:30 – 09:00'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('더보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('일정을 삭제할까요?'), findsOneWidget);

    await tester.tap(find.text('이 일정만 삭제'));
    await tester.pumpAndSettle();
    expect(find.text('회사 출근'), findsNothing);
    expect(find.text('일정 5건'), findsOneWidget);
  });

  testWidgets('일정을 왼쪽으로 밀면 날짜 변경·삭제가 드러나고, 취소하면 그대로 남는다', (tester) async {
    await pumpList(tester);
    final row = find.text('팀 점심');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.drag(row, const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('날짜 변경'), findsOneWidget);

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('일정을 삭제할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.text('팀 점심'), findsOneWidget);
  });

  testWidgets('틀어진 일정 맞추기 → AI 분석 중 → 제안대로 맞추기로 일정이 바뀐다', (tester) async {
    await pumpList(tester);

    await tester.ensureVisible(find.text('틀어진 일정 맞추기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('틀어진 일정 맞추기'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ListAiAnalyzing), findsOneWidget);
    expect(find.textContaining('AI가 틀어진 일정을 맞추고 있어요'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(ListAiAnalyzing), findsNothing);
    expect(find.byType(ListAiSuggestionScreen), findsOneWidget);
    expect(find.text('점심을 30분 미루면 다 지킬 수 있어요'), findsOneWidget);

    await tester.ensureVisible(find.text('제안대로 맞추기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('제안대로 맞추기'));
    await tester.pumpAndSettle();
    expect(find.byType(ListAiSuggestionScreen), findsNothing);
    expect(find.text('제안대로 일정을 맞췄어요.'), findsOneWidget);

    await tester.tap(find.text('J모드'));
    await tester.pumpAndSettle();
    expect(find.text('PM 01:00'), findsOneWidget);
    expect(find.text('PM 02:35'), findsOneWidget);
  });

  testWidgets('AI 분석 중 취소하면 목록으로 돌아온다', (tester) async {
    await pumpList(tester);
    await tester.ensureVisible(find.text('틀어진 일정 맞추기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('틀어진 일정 맞추기'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.byType(ListAiAnalyzing), findsNothing);
    expect(find.byType(ListAiSuggestionScreen), findsNothing);
  });

  testWidgets('지도 탭을 누르면 지도 화면으로 간다', (tester) async {
    // 지도 화면 자체의 레이아웃 경고(테스트 글꼴)는 이 이동 테스트와 무관하므로 무시한다.
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);
    await pumpList(tester);
    await tester.tap(find.text('지도'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(MapScreen), findsOneWidget);
  });
}
