import 'package:axis_app/screens/badge/badge_celebration.dart';
import 'package:axis_app/screens/badge/badge_data.dart';
import 'package:axis_app/screens/badge/badge_detail_screen.dart';
import 'package:axis_app/screens/badge/badge_storage_screen.dart';
import 'package:axis_app/widgets/kit/kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 설정하면 화면 그림을 이 폴더에 남긴다(디자인 비교용): flutter test --dart-define=SHOTS=/경로
const _shots = String.fromEnvironment('SHOTS');

Future<void> _settle(WidgetTester tester, [int ms = 800]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pump(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: home));
  await _settle(tester);
  expect(tester.takeException(), isNull);
}

Future<void> _shot(WidgetTester tester, String name) async {
  if (_shots.isEmpty) return;
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('$_shots/$name.png'));
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

  testWidgets('배지 보관함: 획득 6 · 획득 전 3, 칸을 누르면 상세', (tester) async {
    await _pump(tester, const BadgeStorageScreen());
    await _shot(tester, '11_storage');
    expect(find.text('각성의 순간'), findsOneWidget);
    expect(find.text('5/7일'), findsOneWidget);

    await tester.tap(find.text('각성의 순간'));
    await _settle(tester);
    expect(find.byType(BadgeDetailScreen), findsOneWidget);
    expect(find.text('상위 23%'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('뒤로'));
    await _settle(tester);

    await tester.ensureVisible(find.text('새벽의 축'));
    await tester.tap(find.text('새벽의 축'));
    await _settle(tester);
    expect(find.text('미획득'), findsOneWidget);
    expect(find.text('5 / 7일'), findsOneWidget);
    expect(find.text('2일만 더 하면 획득해요'), findsOneWidget);
  });

  testWidgets('필터로 획득 전 배지만 본다', (tester) async {
    await _pump(tester, const BadgeStorageScreen());
    await tester.tap(find.byTooltip('배지 보기 필터'));
    await _settle(tester);
    await tester.tap(find.text('미획득').last);
    await _settle(tester);
    expect(find.text('각성의 순간'), findsNothing);
    expect(find.text('새벽의 축'), findsOneWidget);
  });

  testWidgets('배지 상세 두 상태는 넘치지 않는다', (tester) async {
    await _pump(tester, BadgeDetailScreen(badge: badgeFor(AxisMedal.awakening)));
    await _shot(tester, '11_detail');
    await tester.tap(find.text('공유하기'));
    await _settle(tester, 2500);

    await _pump(tester, BadgeDetailScreen(badge: badgeFor(AxisMedal.dawnAxis)));
    await _shot(tester, '11_detail_locked');
    expect(find.text('이번 주 기록'), findsOneWidget);
    expect(find.text('일정 보러가기'), findsOneWidget);
  });

  testWidgets('배지 획득 축하: 카드를 누르면 배지 보관함, 바깥을 누르면 닫힌다', (tester) async {
    await _pump(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showBadgeCelebration(context, medal: AxisMedal.awakening),
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await _settle(tester);
    await _shot(tester, '11-1_celebration');
    expect(find.text('일정을 7회 완료했어요. 꾸준함이 시작됐어요!'), findsOneWidget);

    await tester.tap(find.text('이미지 저장'));
    await _settle(tester);
    expect(find.text('이미지를 저장했어요'), findsOneWidget);
    await _settle(tester, 2500);

    await tester.tapAt(const Offset(20, 60));
    await _settle(tester);
    expect(find.byType(BadgeCelebration), findsNothing);

    await tester.tap(find.text('열기'));
    await _settle(tester);
    await tester.tap(find.text('일정을 7회 완료했어요. 꾸준함이 시작됐어요!'));
    await _settle(tester);
    expect(find.byType(BadgeCelebration), findsNothing);
    expect(find.byType(BadgeStorageScreen), findsOneWidget);
  });

  testWidgets('보관함 제목을 길게 누르면 축하 화면 미리보기', (tester) async {
    await _pump(tester, const BadgeStorageScreen());
    await tester.longPress(find.text('획득한 배지 6', findRichText: true));
    await _settle(tester);
    expect(find.byType(BadgeCelebration), findsOneWidget);
  });
}
