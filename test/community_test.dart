import 'dart:io';

import 'package:axis_app/screens/community/community_data.dart';
import 'package:axis_app/screens/community/community_screen.dart';
import 'package:axis_app/screens/community/plan_detail_screen.dart';
import 'package:axis_app/screens/community/plan_overview_tab.dart';
import 'package:axis_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 스켈레톤 깜빡임이 반복돼 pumpAndSettle 대신 일정 시간만 흘린다.
Future<void> _settle(WidgetTester tester, [int ms = 800]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// SHOT_DIR 환경 변수가 있으면 화면을 PNG로 남긴다(flutter test --update-goldens로 실행).
Future<void> _shot(WidgetTester tester, String name) async {
  final dir = Platform.environment['SHOT_DIR'];
  if (dir == null) return;
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
    final ctx = tester.element(find.byType(Scaffold).last);
    await precacheImage(const AssetImage('assets/images/community/hero_bg.png'), ctx);
  });
  await tester.pump();
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('$dir/$name.png'));
}

Future<void> _pump(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: home));
  await _settle(tester);
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

  testWidgets('09 커뮤니티는 로딩 스켈레톤 뒤에 인기 템플릿을 보여 주고 카드로 상세를 연다', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const CommunityScreen()));
    await _settle(tester, 300);
    expect(find.text('비전공생의 CPA 공부 계획'), findsNothing);
    await _shot(tester, 'community_09_loading');
    await _settle(tester, 1000);
    expect(find.text('비전공생의 CPA 공부 계획'), findsOneWidget);
    expect(find.text('1 / 4', findRichText: true), findsOneWidget);
    expect(find.text('혼자 짜는 막막한\n계획은 이제 그만!'), findsOneWidget);
    await _shot(tester, 'community_09');

    await tester.tap(find.bySemanticsLabel('다음 후기'));
    await _settle(tester, 500);
    expect(find.text('2 / 4', findRichText: true), findsOneWidget);

    await tester.ensureVisible(find.text('-20kg 성공한 다이어트 루틴'));
    await tester.tap(find.text('-20kg 성공한 다이어트 루틴'));
    await _settle(tester);
    expect(find.byType(PlanDetailScreen), findsOneWidget);
    expect(find.text('준비물'), findsOneWidget);
  });

  testWidgets('계획 상세는 탭으로 계획서·후기·댓글을 오가고 일정 담기 토스트를 띄운다', (tester) async {
    await _pump(tester, PlanDetailScreen(template: communityTemplates.first));
    expect(find.text('비전공생의 CPA 공부 계획'), findsOneWidget);
    expect(find.text('재무회계 기본서'), findsOneWidget);
    await _shot(tester, 'community_0901');

    await tester.tap(find.text('일정에 추가하기'));
    await _settle(tester, 400);
    expect(find.text('내 일정에 담았어요'), findsOneWidget);
    await _shot(tester, 'community_0901_added');
    await _settle(tester, 2600);

    await tester.scrollUntilVisible(
      find.text('준비물 6개 모두 보기'),
      200,
      scrollable: find.descendant(of: find.byType(PlanOverviewTab), matching: find.byType(Scrollable)).first,
    );
    await _settle(tester, 300);
    await tester.tap(find.text('준비물 6개 모두 보기'));
    await _settle(tester, 400);
    expect(find.text('오답노트'), findsOneWidget);

    await tester.tap(find.text('후기'));
    await _settle(tester);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('합격한 감자'), findsOneWidget);
    await _shot(tester, 'community_0902');
    await tester.tap(find.text('합격 인증 23'));
    await _settle(tester, 300);
    expect(find.text('퇴근 후 회계사'), findsNothing);

    await tester.tap(find.text('댓글'));
    await _settle(tester);
    expect(find.text('댓글 56'), findsOneWidget);
    expect(find.text('스터디메이트'), findsOneWidget);
    expect(find.text('일정에 추가하기'), findsNothing);
    await _shot(tester, 'community_0903');

    await tester.enterText(find.byType(TextField), '저도 따라 해볼게요!');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('등록'));
    await _settle(tester, 400);
    expect(find.text('저도 따라 해볼게요!'), findsOneWidget);
    expect(find.text('댓글 57'), findsOneWidget);
    await _settle(tester, 2600);
  });

  testWidgets('댓글이 없으면 빈 상태를 보여 준다', (tester) async {
    await _pump(tester, PlanDetailScreen(template: communityTemplates.first, initialTab: 2, comments: []));
    expect(find.text('댓글 0'), findsOneWidget);
    expect(find.text('아직 댓글이 없어요'), findsOneWidget);
    await _shot(tester, 'community_0903_empty');
  });

  testWidgets('검색 결과가 없으면 빈 상태, 버튼으로 돌아간다', (tester) async {
    await _pump(tester, const CommunityScreen(loadingDuration: Duration.zero));
    await tester.tap(find.bySemanticsLabel('계획 검색'));
    await _settle(tester);
    expect(find.byType(CommunitySearchScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField), '토익 900 단기');
    await _settle(tester, 300);
    expect(find.text('검색 결과 0'), findsOneWidget);
    expect(find.text("'토익 900 단기' 검색 결과가 없어요"), findsOneWidget);
    await _shot(tester, 'community_search_empty');

    await tester.enterText(find.byType(TextField), '다이어트');
    await _settle(tester, 300);
    expect(find.text('검색 결과 1'), findsOneWidget);
    expect(find.text('-20kg 성공한 다이어트 루틴'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '없는말');
    await _settle(tester, 300);
    await tester.tap(find.text('인기 템플릿 둘러보기'));
    await _settle(tester);
    expect(find.byType(CommunitySearchScreen), findsNothing);
    expect(find.byType(CommunityScreen), findsOneWidget);
  });
}
