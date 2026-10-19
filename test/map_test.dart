import 'package:axis_app/screens/main/map_ai_screen.dart';
import 'package:axis_app/screens/main/map_data.dart';
import 'package:axis_app/screens/main/map_full_screen.dart';
import 'package:axis_app/screens/main/map_screen.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() => MaterialApp(
  theme: buildAppTheme(),
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MapScreen())),
          child: const Text('open'),
        ),
      ),
    ),
  ),
);

Future<void> _openMap(WidgetTester tester) async {
  await tester.pumpWidget(_app());
  await tester.tap(find.text('open'));
  await _settle(tester);
  expect(find.byType(MapScreen), findsOneWidget);
}

/// 반복 애니메이션(선택 핀 고리)이 있어 pumpAndSettle 대신 일정 시간만 흘린다.
Future<void> _settle(WidgetTester tester, [int ms = 800]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
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

  testWidgets('지도 화면이 일정 목록과 요약을 보여 주고 뒤로 돌아간다', (tester) async {
    await _openMap(tester);
    await _settle(tester);
    expect(find.text('전체 일정'), findsOneWidget);
    expect(find.text('일정 6건'), findsOneWidget);
    expect(find.text('약 1시간 · 17.5km'), findsOneWidget);
    expect(find.text('회사 출근'), findsOneWidget);
    expect(find.text('준비 설정 시간(20분)'), findsOneWidget);

    await tester.tap(find.byTooltip('뒤로'));
    await _settle(tester);
    expect(find.byType(MapScreen), findsNothing);
  });

  testWidgets('일정 카드를 누르면 장소 상세 시트가 열리고 닫힌다', (tester) async {
    await _openMap(tester);
    await tester.ensureVisible(find.text('고객사 미팅'));
    await tester.tap(find.text('고객사 미팅'));
    await _settle(tester);
    expect(find.byType(PlaceDetailSheet), findsOneWidget);
    expect(find.text('토스증권'), findsWidgets);
    expect(find.text('PM 03:00 도착'), findsOneWidget);

    await tester.tap(find.byTooltip('닫기'));
    await _settle(tester);
    expect(find.byType(PlaceDetailSheet), findsNothing);
  });

  testWidgets('확대 버튼으로 지도 크게 보기를 열고 카드를 넘긴다', (tester) async {
    await _openMap(tester);
    await tester.tap(find.bySemanticsLabel('지도 크게 보기'));
    await _settle(tester);
    expect(find.byType(MapFullScreen), findsOneWidget);
    expect(find.text('1 / 6'), findsOneWidget);

    await tester.drag(find.text('회사 출근').last, const Offset(-300, 0));
    await _settle(tester);
    expect(find.text('2 / 6'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('지도 작게 보기'));
    await _settle(tester);
    expect(find.byType(MapFullScreen), findsNothing);
  });

  testWidgets('동선 최적화: 분석 후 제안을 적용하면 러닝 시간이 바뀐다', (tester) async {
    await _openMap(tester);
    await tester.tap(find.bySemanticsLabel('동선 최적화하기'));
    await _settle(tester, 400);
    expect(find.byType(MapAiAnalysisScreen), findsOneWidget);
    expect(find.text('오늘 일정 6개 불러오기'), findsOneWidget);

    await _settle(tester, 3000);
    expect(find.byType(MapAiSuggestionScreen), findsOneWidget);
    expect(find.text('이 순서로 움직이면 15분 아껴요'), findsOneWidget);

    await tester.tap(find.text('제안대로 바꾸기'));
    await _settle(tester);
    expect(find.byType(MapAiSuggestionScreen), findsNothing);
    expect(find.text('약 45분 · 10.9km'), findsOneWidget);
    expect(find.text('PM 04:30'), findsOneWidget);
  });

  testWidgets('분석 중 취소하면 지도 화면으로 돌아간다', (tester) async {
    await _openMap(tester);
    await tester.tap(find.bySemanticsLabel('동선 최적화하기'));
    await _settle(tester, 500);
    await tester.tap(find.text('취소'));
    await _settle(tester);
    expect(find.byType(MapAiAnalysisScreen), findsNothing);
    expect(find.text('약 1시간 · 17.5km'), findsOneWidget);
  });
}
