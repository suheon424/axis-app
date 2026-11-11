import 'package:axis_app/screens/main/map_ai_screen.dart';
import 'package:axis_app/screens/main/map_data.dart';
import 'package:axis_app/screens/main/map_full_screen.dart';
import 'package:axis_app/screens/main/map_screen.dart';
import 'package:axis_app/screens/main/schedule_list_screen.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:axis_app/widgets/kit/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 일정 목록(07_05)에서 지도 탭을 누른다. 같은 화면 안에서 탭만 바뀐다.
Future<void> _openMap(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const ScheduleListScreen()));
  await _settle(tester);
  await tester.tap(find.text('지도'));
  await _settle(tester);
  expect(find.byType(MapTab), findsOneWidget);
}

/// 지도 탭만 띄운다(상태 데모용).
Future<void> _pumpTab(WidgetTester tester, Widget tab) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: SingleChildScrollView(child: tab)),
    ),
  );
  await _settle(tester);
}

/// 반복 애니메이션(AI 구슬·단계 고리)이 있어 pumpAndSettle 대신 일정 시간만 흘린다.
Future<void> _settle(WidgetTester tester, [int ms = 800]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// 처음 최적화를 누르면 뜨는 위치 권한 요청에 답한다.
Future<void> _startOptimize(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('동선 최적화하기'));
  await _settle(tester, 400);
  expect(find.text('위치 권한이 필요해요'), findsOneWidget);
  await tester.tap(find.text('허용하기'));
  await _settle(tester, 400);
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

  tearDown(hideAxisToast);

  testWidgets('지도 탭은 같은 화면에서 그날 타임라인을 보여 주고 목록 탭으로 돌아간다', (tester) async {
    await _openMap(tester);
    expect(find.text('11월 23일 월요일'), findsOneWidget);
    expect(find.text('일정 6개'), findsOneWidget);
    expect(find.text('회사 출근'), findsOneWidget);
    expect(find.text('2호선 공덕 방면'), findsOneWidget);
    expect(find.text('이날 일정 추가하기'), findsOneWidget);
    expect(find.bySemanticsLabel('3번 팀 점심 핀'), findsOneWidget);

    await tester.tap(find.text('목록'));
    await _settle(tester);
    expect(find.byType(MapTab), findsNothing);
  });

  testWidgets('일정이 없는 날은 빈 상태를 보여 준다', (tester) async {
    await _pumpTab(tester, const MapTab(day: 24));
    expect(find.text('11월 24일 화요일'), findsOneWidget);
    expect(find.text('이 날은 아직 일정이 없어요'), findsOneWidget);
    expect(find.text('회사 출근'), findsNothing);
  });

  testWidgets('타임라인 줄을 누르면 장소 상세 시트가 열리고 닫힌다', (tester) async {
    await _openMap(tester);
    await tester.ensureVisible(find.text('고객사 미팅'));
    await tester.tap(find.text('고객사 미팅'));
    await _settle(tester);
    expect(find.byType(PlaceDetailSheet), findsOneWidget);
    expect(find.text('토스증권'), findsWidgets);
    expect(find.text('03:00 PM 도착'), findsOneWidget);
    expect(find.text('길찾기'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('닫기'));
    await _settle(tester);
    expect(find.byType(PlaceDetailSheet), findsNothing);
  });

  testWidgets('지도를 길게 누르면 오류 상태가 되고 다시 시도로 돌아온다', (tester) async {
    await _pumpTab(tester, const MapTab(day: 23));
    await tester.longPress(find.bySemanticsLabel('집 핀'));
    await _settle(tester);
    expect(find.text('지도를 불러오지 못했어요'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await _settle(tester, 1000);
    expect(find.text('지도를 불러오지 못했어요'), findsNothing);
    expect(find.bySemanticsLabel('집 핀'), findsOneWidget);
  });

  testWidgets('위치 권한 요청: 열 때 묻는 데모 플래그', (tester) async {
    await _pumpTab(tester, const MapTab(day: 23, askLocationOnOpen: true));
    expect(find.text('위치 권한이 필요해요'), findsOneWidget);
    expect(find.text('내 위치를 기준으로 동선을 추천해 드려요.'), findsOneWidget);
    await tester.tap(find.text('나중에'));
    await _settle(tester);
    expect(find.text('위치 권한이 필요해요'), findsNothing);
  });

  testWidgets('확대 버튼으로 지도 크게 보기를 열고 카드를 넘긴다', (tester) async {
    await _openMap(tester);
    await tester.tap(find.bySemanticsLabel('지도 크게 보기'));
    await _settle(tester);
    expect(find.byType(MapFullScreen), findsOneWidget);
    expect(find.textContaining('일정 6건', findRichText: true), findsOneWidget);

    await tester.drag(find.text('회사 출근').last, const Offset(-300, 0));
    await _settle(tester);
    // 두 번째 카드가 선택되면 같은 핀을 누를 때 상세 시트가 열린다.
    await tester.tap(find.bySemanticsLabel('2번 기획안 제출 핀'));
    await _settle(tester);
    expect(find.byType(PlaceDetailSheet), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('닫기'));
    await _settle(tester);

    await tester.tap(find.bySemanticsLabel('지도 작게 보기'));
    await _settle(tester);
    expect(find.byType(MapFullScreen), findsNothing);
  });

  testWidgets('동선 최적화: 권한 요청 → 분석 → 제안을 적용하면 러닝 시간이 바뀐다', (tester) async {
    await _openMap(tester);
    await _startOptimize(tester);
    expect(find.byType(MapAiAnalysisScreen), findsOneWidget);
    expect(find.text('오늘 일정 6개 불러오기'), findsOneWidget);
    expect(find.text('AI가 동선을 다시 짜고 있어요'), findsOneWidget);

    await _settle(tester, 3000);
    expect(find.byType(MapAiSuggestionScreen), findsOneWidget);
    expect(find.text('AI 동선 맞추기'), findsOneWidget);
    expect(find.text('러닝을 미팅 직후로 옮기면 이동이 6.6km 줄어요'), findsOneWidget);

    await tester.tap(find.text('제안대로 맞추기'));
    await _settle(tester);
    expect(find.byType(MapAiSuggestionScreen), findsNothing);
    expect(find.text('04:30 PM'), findsOneWidget);
    expect(find.text('러닝을 04:30 PM으로 옮겼어요'), findsOneWidget);
    await _settle(tester, 2500);
  });

  testWidgets('분석 중 취소하면 지도 화면으로 돌아간다', (tester) async {
    await _openMap(tester);
    await _startOptimize(tester);
    await tester.tap(find.text('맞추기 취소'));
    await _settle(tester);
    expect(find.byType(MapAiAnalysisScreen), findsNothing);
    expect(find.text('07:30 PM'), findsOneWidget);
  });
}
