import 'package:axis_app/widgets/kit/kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 반복 애니메이션(스켈레톤·스피너)이 있어 pumpAndSettle 대신 일정 시간만 흘린다.
Future<void> _settle(WidgetTester tester, [int ms = 600]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery();

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  bool toggle = true;
  int seg = 0;
  int page = 1;
  bool dontShow = false;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 12);
    return Scaffold(
      appBar: const AxisBackTitleBar(title: '키트 갤러리'),
      bottomNavigationBar: const AxisTabBar(current: MainTab.planner),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AxisBackShareBar(title: '템플릿', onShare: () {}),
            const AxisGreetingBanner(name: '수현 님', message: '달성률이 높아졌어요. 잘하고 있어요!'),
            gap,
            AxisCtaButton(label: '로그인', onPressed: () {}),
            gap,
            AxisCtaButton(label: '아주 긴 버튼 문구가 들어가도 줄이 바뀌며 상자가 함께 늘어나야 해요', onPressed: () {}, enabled: false),
            gap,
            AxisSplitButton(leftLabel: '잘 모르겠어요', rightLabel: '선택 완료', onLeft: () {}, onRight: () {}),
            gap,
            AxisSplitButton(
              tone: AxisSplitTone.red,
              leftLabel: '이 일정만 삭제',
              rightLabel: '이후 일정 삭제',
              onLeft: () {},
              onRight: () {},
            ),
            gap,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AxisSmallButton(label: '인기 템플릿 둘러보기', onPressed: () {}),
                AxisSmallButton(label: '인기 템플릿 둘러보기', outline: true, onPressed: () {}),
                AxisSmallButton(label: '비활성', enabled: false, onPressed: () {}),
                AxisBuyButton(onPressed: () {}),
                AxisAddIconButton(onPressed: () {}),
                AxisHelpfulButton(count: 42, onPressed: () {}),
                AxisHelpfulButton(count: 7, selected: true, onPressed: () {}),
                AxisDirectionsButton(onPressed: () {}),
                AxisIconButton.back(floating: true),
                AxisIconButton(icon: KitIcon.navShare, tooltip: '공유', onPressed: () {}),
                AxisIconButton(icon: KitIcon.navBookmarkOn, tooltip: '북마크', onPressed: () {}),
                const AxisCloseButton(),
                AxisToggle(value: toggle, onChanged: (v) => setState(() => toggle = v)),
                const AxisToggle(value: false, onChanged: null),
                AxisChip(label: '40분', selected: true, onTap: () {}),
                AxisChip(label: '60분', selected: false, onTap: () {}),
                const AxisRadio(selected: true),
                const AxisRadio(selected: false),
                const AxisColorSwatch(color: CubeColors.yellow, selected: true),
                const AxisColorSwatch(color: CubeColors.green, selected: false),
              ],
            ),
            gap,
            AxisStepper(value: '40분', caption: '10분 단위로 조절', onMinus: () {}, onPlus: null),
            const AxisSectionTitle('섹션 제목'),
            const AxisGroupLabel('알림'),
            AxisSettingRow(title: '전체 알림', value: toggle, onChanged: (v) => setState(() => toggle = v)),
            AxisSettingRow(title: '일정 시작 전 알림', description: '10분 전에 알려드려요', value: true, onChanged: (_) {}),
            const AxisDivider(),
            AxisMenuRow(icon: KitIcon.menuBadge, label: '나의 배지', onTap: () {}),
            AxisMenuRow(icon: KitIcon.menuInfo, label: '버전 정보', value: '11.23.0', onTap: () {}),
            AxisCategoryRow(color: AppColors.brand, title: 'Todo', subtitle: '30일 중 18일 실천', percent: 60, onTap: () {}),
            const AxisSectionDivider(),
            gap,
            AxisCategoryCard(title: 'Todo', days: List.generate(30, (i) => i < 18), onTap: () {}),
            gap,
            const AxisTemplateInfo(
              title: '-20kg 성공한 다이어트 루틴',
              description: '무리하지 않는 하루 5개 루틴으로 성공!',
              meta: '3달 소요',
              footnote: '댓글 99+ · 매력둥이gdken',
            ),
            gap,
            AxisSegmentedTabs(
              labels: const ['계획서', '후기', '댓글'],
              selected: seg,
              onChanged: (i) => setState(() => seg = i),
            ),
            gap,
            AxisSegmentedTabs(labels: const ['목록', '지도'], selected: 1, onChanged: (_) {}),
            gap,
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(8),
              child: AxisPillSegment(labels: const ['목록', '달성률'], selected: 0, onChanged: (_) {}),
            ),
            gap,
            const AxisWeekdayHeader(highlight: 1),
            AxisMonthHeader(title: '2026년 11월', onPrev: () {}),
            const Row(
              children: [
                AxisCalendarDay(day: 8, state: AxisDayState.inProgress),
                AxisCalendarDay(day: 9, state: AxisDayState.done),
                AxisCalendarDay(day: 10, state: AxisDayState.scheduled),
                AxisCalendarDay(day: 11, state: AxisDayState.today),
                AxisCalendarDay(day: 12, state: AxisDayState.empty),
              ],
            ),
            const AxisDayLegendItem(state: AxisDayState.inProgress, label: '진행 중', description: '일정을 일부 실천했어요'),
            AxisScheduleDayHeader(
              title: '11월 23일 월요일',
              countLabel: '일정 6개',
              jMode: false,
              onJModeTap: () {},
              filterLabel: '전체',
              onFilterTap: () {},
            ),
            gap,
            const AxisTimelineStartRow(time: '07:55 AM', title: '집', place: '서울 · 마포구', prepValue: '20분'),
            const AxisTimelineTransitRow(
              duration: '15분 소요\n3.5km',
              mode: '지하철',
              route: '광흥창역 → 공덕역',
              detail: '2호선 공덕 방면',
            ),
            const AxisTimelinePlaceRow(time: '08:30 AM', number: 1, title: '회사 출근', place: '브릿지파트너스'),
            const Row(
              children: [
                AxisTimelineMarker(number: 1),
                AxisTimelineMarker(number: 2, state: AxisMarkerState.current),
                AxisTimelineMarker(number: 3, state: AxisMarkerState.upcoming),
                AxisTimelineMarker(number: 4, state: AxisMarkerState.done),
              ],
            ),
            gap,
            Container(
              color: const Color(0xFF1F2126),
              padding: const EdgeInsets.all(12),
              child: const Column(
                children: [
                  AxisStepBar(total: 6, done: 2),
                  SizedBox(height: 12),
                  AxisStepItem(label: '오늘 일정 6개 불러오기', state: AxisStepState.done),
                  AxisStepItem(label: '이동 경로 12가지 비교 중', state: AxisStepState.now),
                  AxisStepItem(label: '가장 짧은 동선 제안하기', state: AxisStepState.todo),
                ],
              ),
            ),
            gap,
            const AxisMiniBar(value: 0.6),
            const AxisSkeletonBar(),
            AxisPager(page: page, count: 6, onChanged: (p) => setState(() => page = p)),
            gap,
            const Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                AxisTag('Pace', tone: AxisTagTone.red),
                AxisTag('Pace', tone: AxisTagTone.green),
                AxisTag('Pace'),
                AxisTag('Pace', tone: AxisTagTone.orange),
                AxisTag('Pace', tone: AxisTagTone.gray),
                AxisTag('Pace', tone: AxisTagTone.neutral),
                AxisTag('Pace', tone: AxisTagTone.dark),
                AxisEventStatusBadge(status: AxisEventStatus.joined),
                AxisEventStatusBadge(status: AxisEventStatus.join),
                AxisEventStatusBadge(status: AxisEventStatus.done),
                AxisHeroPill('7일 남음'),
                AxisNumberBadge(2),
                AxisNumberBadge(2, blue: true),
                AxisRankBadge(1, top: true),
                AxisRankBadge(2),
                AxisNotificationBadge(count: 3),
                AxisNotificationBadge(),
                AxisCompareBadge(after: false),
                AxisCompareBadge(after: true),
              ],
            ),
            gap,
            const Row(
              children: [
                AxisBadgeItem(medal: AxisMedal.awakening, caption: '일정 7회 완료'),
                AxisBadgeItem(medal: AxisMedal.perfectWeek, caption: '일정 7회 완료', progress: 0.7),
              ],
            ),
            gap,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const AxisAvatar(character: 1, selected: true),
                const AxisAvatar(character: 12),
                for (final t in AxisEventIconType.values) AxisEventIcon(t),
                const AxisMapPin(number: 1),
                const AxisMapPin(home: true),
                const AxisAiOrb(size: 60),
              ],
            ),
            gap,
            AxisEmptyState(
              title: '아직 저장한 템플릿이 없어요',
              description: '마음에 드는 계획을 북마크해 두면 여기에 모여요.',
              actionLabel: '인기 템플릿 둘러보기',
              onAction: () {},
            ),
            gap,
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(12),
              child: AxisCoachmarkBottomBar(
                dontShowAgain: dontShow,
                onDontShowAgainChanged: (v) => setState(() => dontShow = v),
                onClose: () {},
              ),
            ),
            gap,
            const AxisSheetHeader(title: '평소 준비시간'),
            AxisSheetHeader(title: '회사 출근', onMore: () {}),
            const AxisSheetHeader(title: 'AI 동선 맞추기', ai: true),
            gap,
            const AxisToast(message: '저장했어요', actionLabel: '보기'),
            gap,
            AxisConfirmDialog(
              title: '일정을 삭제할까요?',
              message: '삭제한 일정은 되돌릴 수 없어요.',
              confirmLabel: '이 일정만 삭제',
              otherLabel: '이후 일정 삭제',
              onConfirm: () {},
              onOther: () {},
            ),
            Builder(
              builder: (context) => Row(
                children: [
                  TextButton(
                    onPressed: () => showAxisToast(context, '저장했어요', actionLabel: '보기'),
                    child: const Text('토스트'),
                  ),
                  TextButton(
                    onPressed: () => showAxisConfirm(context, title: '일정을 삭제할까요?', confirmLabel: '삭제'),
                    child: const Text('확인창'),
                  ),
                  TextButton(
                    onPressed: () => showAxisSheet<void>(
                      context,
                      title: '평소 준비시간',
                      builder: (_) => const Text('시트 내용'),
                      footer: (_) => AxisCtaButton(label: '확인', onPressed: () {}),
                    ),
                    child: const Text('시트'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  testWidgets('키트 갤러리가 넘침 없이 그려지고 탭·토글이 동작한다', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const _Gallery()));
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('AI 플래너'), findsOneWidget);

    await tester.ensureVisible(find.text('후기'));
    await _settle(tester);
    await tester.tap(find.text('후기'));
    await _settle(tester);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byType(AxisToggle).first);
    await tester.tap(find.byType(AxisToggle).first);
    await _settle(tester);
    expect(tester.takeException(), isNull);

    // 하단 탭: onTap이 없으면 준비 중 안내가 뜨고, 뒤집히는 애니메이션도 문제없이 끝난다.
    await tester.tap(find.text('탐색'));
    await _settle(tester);
    expect(find.text('탐색은(는) 준비 중이에요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('토스트·확인창·시트를 함수로 띄운다', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const _Gallery()));
    await _settle(tester);

    await tester.ensureVisible(find.text('토스트'));
    await tester.tap(find.text('토스트'));
    await _settle(tester);
    expect(find.text('저장했어요'), findsNWidgets(2));
    await _settle(tester, 2200);
    expect(find.text('저장했어요'), findsOneWidget);

    await tester.tap(find.text('확인창'));
    await _settle(tester);
    expect(find.text('삭제'), findsOneWidget);
    await tester.tap(find.text('삭제'));
    await _settle(tester);
    expect(find.text('삭제'), findsNothing);

    await tester.tap(find.text('시트'));
    await _settle(tester);
    expect(find.text('시트 내용'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
