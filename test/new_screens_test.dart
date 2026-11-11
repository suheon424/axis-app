import 'package:axis_app/screens/community/all_templates_screen.dart';
import 'package:axis_app/screens/community/community_notifications_screen.dart';
import 'package:axis_app/screens/my/my_data.dart';
import 'package:axis_app/screens/my/point_shop_screen.dart';
import 'package:axis_app/screens/password_reset_screen.dart';
import 'package:axis_app/widgets/kit/kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _settle(WidgetTester tester, [int ms = 800]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: screen));
  await _settle(tester);
}

void main() {
  testWidgets('03-1 이메일을 넣으면 재설정 링크 받기가 켜지고 03-2로 넘어간다', (tester) async {
    await _pump(tester, const PasswordResetScreen());
    await tester.enterText(find.byType(EditableText), 'suhyun424@hansung.ac.kr');
    await _settle(tester);
    await tester.tap(find.text('재설정 링크 받기'));
    await _settle(tester);
    expect(find.text('메일을 보냈어요'), findsOneWidget);
    expect(find.text('suhyun424@hansung.ac.kr'), findsOneWidget);
    await tester.tap(find.text('메일 다시 보내기'));
    await _settle(tester);
    expect(find.text('메일을 다시 보냈어요'), findsOneWidget);
    await _settle(tester, 2600);
  });

  testWidgets('09-4 안 읽은 알림을 누르면 N 배지가 사라진다', (tester) async {
    communityUnread.value = {0, 1, 2};
    await _pump(tester, const CommunityNotificationsScreen());
    expect(find.text('N'), findsNWidgets(3));
    await tester.tap(find.text('기획안 제출이 40분 밀렸어요'));
    await _settle(tester);
    expect(find.text('N'), findsNWidgets(2));
  });

  testWidgets('09-5 칩으로 템플릿을 거른다', (tester) async {
    await _pump(tester, AllTemplatesScreen(onOpen: (_) {}));
    expect(find.text('전체 템플릿 128', findRichText: true), findsOneWidget);
    await tester.tap(find.text('운동'));
    await _settle(tester);
    expect(find.text('-20kg 성공한 다이어트 루틴'), findsOneWidget);
    expect(find.text('비전공생의 CPA 공부 계획'), findsNothing);
    await tester.tap(find.text('여행'));
    await _settle(tester);
    expect(find.text('아직 템플릿이 없어요'), findsOneWidget);
  });

  testWidgets('12-2-1 교환하면 포인트가 줄고 보유 중이 된다', (tester) async {
    myProfile.value = myProfile.value.copyWith(points: 1550);
    ownedShopItems.value = {'theme_dawn'};
    await _pump(tester, const PointShopScreen());
    expect(find.text('1,550P'), findsOneWidget);
    expect(find.text('450P 부족'), findsOneWidget);
    await tester.tap(find.text('테마 ‘오로라 그린’'));
    await _settle(tester);
    await tester.tap(find.text('교환하기').last);
    await _settle(tester);
    expect(find.text('1,050P'), findsOneWidget);
    expect(find.text('보유 중'), findsNWidgets(2));
    await _settle(tester, 2600);
    myProfile.value = myProfile.value.copyWith(points: 1550);
    ownedShopItems.value = {'theme_dawn'};
  });
}
