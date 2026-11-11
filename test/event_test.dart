import 'package:axis_app/screens/badge/badge_storage_screen.dart';
import 'package:axis_app/screens/event/event_affirmation_screen.dart';
import 'package:axis_app/screens/event/event_attendance_screen.dart';
import 'package:axis_app/screens/event/event_badge_collection_screen.dart';
import 'package:axis_app/screens/event/event_cube_screen.dart';
import 'package:axis_app/screens/event/event_data.dart';
import 'package:axis_app/screens/event/event_invite_screen.dart';
import 'package:axis_app/screens/event/event_plan_king_screen.dart';
import 'package:axis_app/screens/event/event_screen.dart';
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

/// 화면 그림에 이미지가 보이도록 미리 읽어 둔다.
Future<void> _precache(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
}

Future<void> _shot(WidgetTester tester, String name) async {
  if (_shots.isEmpty) return;
  await _precache(tester);
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
    EventStatusStore.reset();
  });

  testWidgets('10_이벤트: 배너와 목록, 목록 줄을 누르면 각 상세로 간다', (tester) async {
    await _pump(tester, const EventScreen());
    await _shot(tester, '10_event');
    expect(find.text('1 / 6', findRichText: true), findsOneWidget);
    expect(find.text('매일 출석하고 포인트와 선물 받아요'), findsOneWidget);
    expect(find.text('참여하기'), findsOneWidget);
    expect(find.text('참여 완료'), findsOneWidget);

    final rows = {
      '매일 출석하고 포인트와 선물 받아요': EventAttendanceScreen,
      '이달의 계획왕에 도전해 보세요!': EventPlanKingScreen,
      '긍정 확언 남기기': EventAffirmationScreen,
      '친구 초대 이벤트': EventInviteScreen,
      '배지 컬렉션': EventBadgeCollectionScreen,
    };
    for (final e in rows.entries) {
      await tester.ensureVisible(find.text(e.key));
      await tester.tap(find.text(e.key));
      await _settle(tester);
      expect(find.byType(e.value), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.bySemanticsLabel('뒤로'));
      await _settle(tester);
    }
  });

  testWidgets('배너를 넘기고 첫 배너를 누르면 큐브 자랑 상세(10-2)', (tester) async {
    await _pump(tester, const EventScreen());
    await tester.tap(find.bySemanticsLabel('다음'));
    await _settle(tester);
    expect(find.text('2 / 6', findRichText: true), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('이전'));
    await _settle(tester);
    await tester.tap(find.byType(PageView), warnIfMissed: false);
    await _settle(tester);
    expect(find.byType(EventCubeScreen), findsOneWidget);
  });

  testWidgets('상세 화면들은 넘치지 않는다', (tester) async {
    final screens = {
      '10-1_attendance': const EventAttendanceScreen(),
      '10-2_cube': const EventCubeScreen(),
      '10-3_plan_king': const EventPlanKingScreen(),
      '10-4_affirmation': const EventAffirmationScreen(),
      '10-5_invite': const EventInviteScreen(),
      '10-6_badge_collection': const EventBadgeCollectionScreen(),
    };
    for (final e in screens.entries) {
      await _pump(tester, e.value);
      await _shot(tester, e.key);
      await tester.drag(find.byType(ListView).first, const Offset(0, -1500));
      await _settle(tester);
      expect(tester.takeException(), isNull);
      await _shot(tester, '${e.key}_bottom');
    }
  });

  testWidgets('오늘 출석하기를 누르면 출석 수가 늘고 버튼이 회색이 된다', (tester) async {
    await _pump(tester, const EventAttendanceScreen());
    expect(find.text('15일'), findsOneWidget);
    await tester.tap(find.text('오늘 출석하기'));
    await _settle(tester);
    expect(find.text('16일'), findsOneWidget);
    expect(find.text('오늘 출석 완료'), findsOneWidget);
    await _settle(tester, 2500);
  });

  testWidgets('계획왕 참여하기를 누르면 목록 상태도 참여 중이 된다', (tester) async {
    await _pump(tester, const EventScreen());
    await tester.ensureVisible(find.text('이달의 계획왕에 도전해 보세요!'));
    await tester.tap(find.text('이달의 계획왕에 도전해 보세요!'));
    await _settle(tester);
    expect(find.text('참여 전'), findsOneWidget);
    await tester.tap(find.text('참여하기').last);
    await _settle(tester);
    expect(EventStatusStore.of(EventKind.planKing), AxisEventStatus.joined);
    expect(find.text('순위에 반영되고 있어요'), findsOneWidget);
    await _settle(tester, 2500);
    await tester.tap(find.bySemanticsLabel('뒤로'));
    await _settle(tester);
    expect(find.text('참여하기'), findsNothing);
  });

  testWidgets('확언 공감, 초대 코드 복사', (tester) async {
    await _pump(tester, const EventAffirmationScreen());
    await tester.ensureVisible(find.text('97'));
    await tester.tap(find.text('97'));
    await _settle(tester);
    expect(find.text('98'), findsOneWidget);

    await _pump(tester, const EventInviteScreen());
    await tester.tap(find.text('복사'));
    await _settle(tester);
    expect(find.text('초대 코드를 복사했어요'), findsOneWidget);
    await _settle(tester, 2500);
  });

  testWidgets('배지 모으러 가기는 배지 보관함(11)으로 간다', (tester) async {
    await _pump(tester, const EventBadgeCollectionScreen());
    expect(find.text('획득 완료'), findsNWidgets(2));
    await tester.tap(find.text('배지 모으러 가기'));
    await _settle(tester);
    expect(find.byType(BadgeStorageScreen), findsOneWidget);
  });
}
