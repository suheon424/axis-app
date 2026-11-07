# axis UI 키트 (리디자인)

피그마 `WCedkMek8MvqyFfsPsz6MV` "Page 1"의 **🧩 axis Components**(130:9182)와 **Patterns**(130:9833)를 옮긴 위젯 모음.

```dart
import 'package:axis_app/widgets/kit/kit.dart'; // 키트 전부 + app_theme.dart + buttons.dart + main_chrome.dart
```

- 파라미터 표기: `name*` = 필수, `= x` = 기본값. 콜백이 `null`이면 그 컨트롤은 눌리지 않는다(대부분 흐리게).
- 글자를 담는 상자는 고정 높이가 아니라 **최소 높이 + 여백**이라 글자가 늘면 함께 늘어난다. 앱 최소 글자 크기는 12.
- 반복 애니메이션이 있는 위젯(`AxisSkeletonBar`, `AxisStepItem(now)`, `AxisAiOrb(pulse: true)`)이 화면에 있으면 테스트에서
  `pumpAndSettle` 대신 일정 시간 `pump`를 반복한다(test/kit_test.dart의 `_settle` 참고).
- 예시 화면 전체: `test/kit_test.dart`의 `_Gallery`.

## 토큰 (lib/theme/app_theme.dart)

새 디자인의 파랑은 **`AppColors.brand` #004FED** (기존 `AppColors.primary` #0057ED는 예전 화면용·cube 색).

| 토큰 | 값 | 쓰임 |
|---|---|---|
| `brand` / `brandPressed` / `brandCorner` / `brandCornerPressed` | #004FED / #003BC4 / #0041B0 / #00318F | 메인 버튼·선택·강조 / 눌림 / CTA 사선 조각 |
| `brandSoft` | #EAF2FF | 연파랑 바탕(참여 중, 추가 버튼, Blue 태그) |
| `brandSky` | #A0D5FF | 현재 마커 고리 |
| `brandStep` | #2F67F0 | 진행 단계 바, 토스트 체크 |
| `disabledFill` / `disabledCorner` | #DCDFE6 / #9EA6B8 | 비활성 버튼 |
| `gray01` | #F4F5FA | 섹션 구분 띠, 눌린 줄 |
| `gray02` | #EDEEF6 | 목록 구분선 1px |
| `gray06` | #636C78 | 기능 아이콘, 보조 글자 |
| `subIcon` | #8B95A1 | 꺼진 탭 글자, 작은 보조 아이콘, 설정 설명 |
| `segmentBg` | #E8ECF4 | 사선 세그먼트 바탕, J모드 칩 |
| `toggleOff`, `neutralText`, `radioBorder`, `toastBg`, `toastAction`, `tabLabelOn`, `weekday` | | 각 컴포넌트 전용 |

글자 스타일 `AxisText`: `sectionTitle`(20 Bold, 섹션·시트 제목) · `navTitle`(18 Bold gray06) · `title18`(18 Bold 검정) ·
`rowTitle`(16 SemiBold) · `rowTitleMedium`(16 Medium) · `body`(14 Regular) · `caption`(12 Regular gray06) ·
`groupLabel`(12 SemiBold gray06, 설정 그룹 라벨) · `button`(16 SemiBold 흰색).

## 아이콘 (icons.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisIcon(name*, size = 24, color, semanticLabel)` | Icon 130:9421 | `name`은 `KitIcon.*` 상수. `color`로 다시 칠함 |
| `AxisChevronRight(size = 24, color)` | Icon/Nav/Back 뒤집기 | 목록 끝 › |

`KitIcon` 이름(assets/icons/kit/*.svg):
- 24px 선 아이콘(1.8, gray06): `navBack navShare navBookmark navBookmarkOn navPlus navClose navMore navExpand navBell navSearch stateAlert statePoint`
- 14px: `smallBookmarkOff/On smallLikeOff/On smallChevronRight chevronDownSmall`, 12px `clockSmall`, 16px `helpful`
- 18px 마이 메뉴(검정): `menuBadge menuPost menuComment menuBookmark menuNotice menuAlarm menuSupport menuInfo`
- 흰색 채움(→ `color`로 칠해 쓰기): `heartOn heartOff plusBold filter alarmOn alarmOff calendar clock trash bus busFilled car walk subway question checkBox shareGraph swipeRight`
- 기타: `clockLine`(18px #8B95A1 선 시계, 장소 카드) `repeat`(#8B95A1 선) `panZoom`(40px) `homeGlyph`(집 모양) `aiSparkle`(파란 그라디언트) `checkWhite`(흰 체크 선) `lock`

3D 메탈 이미지(assets/images/kit/): `medal_*.png`(210px, `AxisMedal`), `event_*.png`(120px, `AxisEventIconType`), `ai_orb.png`(600px, 빛 포함).
캐릭터는 기존 assets/images/characters/char_01~12.png.

## 하단 탭 (lib/widgets/main_chrome.dart)

`AxisTabBar(current*: MainTab, onTap: ValueChanged<MainTab>?, light = true)` — Tab Bar 130:9415 / Bottom Navigation 130:9742. `light: false`는 07_01 홈의 블랙모드 바(#121212).
- 이제 **모든 화면에서 흰 바**(위 0.5px #CCD1DD + 옅은 그림자, 높이 58 + 홈 인디케이터). `light`는 호환용으로 남아 있고 무시된다.
- 탭: 홈 / **AI 플래너** / 탐색 / 이벤트 / 마이 (`MainTab.home/planner/explore/event/my`, 라벨은 `tab.label`).
- 선택: 검정 아이콘(파란 사선) + 12 SemiBold #181920 / 나머지: #CCD1DD 아이콘 + 12 Regular #8B95A1. 바뀔 때 칸이 위아래로 한 번 뒤집힘.
- `onTap`이 없으면 다른 탭을 누를 때 "…은(는) 준비 중이에요." 스낵바.
- Scaffold `bottomNavigationBar:`에 넣는다. 그 위에 토스트를 띄울 땐 `showAxisToast(..., bottom: 82)`.

## 네비게이션 (nav.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisBackTitleBar` | Nav/Back Title 130:9961, Nav/Title 130:9407 | `title*, onBack (없으면 maybePop), actions = [] (오른쪽 44px 버튼들), showBack = true, backgroundColor`. 높이 44, `PreferredSizeWidget`이라 `appBar:`에 바로 사용 |
| `AxisBackShareBar` | Nav/Back Share 130:10085 | `title*, onBack, onShare (null이면 숨김), trailing = []`. 흰 원형 뒤로(그림자) + 가운데 제목 + 공유. 높이 48 |
| `AxisGreetingBanner` | Nav/Greeting 130:9412 | `name*` ("수현 님"), `message*` |

(기존 `AxisNavBar`(form_widgets.dart, 높이 40)는 로그인·가입 화면용으로 그대로 있다.)

## 버튼 (kit_buttons.dart, + 기존 buttons.dart)

| 위젯 | 피그마 | 파라미터 / 동작 |
|---|---|---|
| `AxisCtaButton` | Button 130:9184 Type=Primary | `label*, onPressed*, enabled = true, onDisabledPressed`. 오른쪽 끝 사선 컷 + 진한 조각. 필수 입력 전 `enabled: false`(회색), 눌림 진파랑. 최소 높이 52, 가로 꽉 |
| `AxisSplitButton` | Button Type=2Primary / Dialog/Confirm 버튼 | `leftLabel*, rightLabel*, onLeft*, onRight*, tone = AxisSplitTone.blue, rightEnabled = true, height`. blue: 왼쪽 회색 보조 + 오른쪽 파란 메인(52). red: 왼쪽 빨강 채움 + 오른쪽 빨강 테두리(40) |
| `AxisSmallButton` | Button/Small 130:9975 | `label*, onPressed*, outline = false, enabled = true, expand = false`. 높이 40·굴곡 8, 14 SemiBold |
| `AxisBuyButton` | Button/Buy 130:9905 | `label = '구매', onPressed*`. 굴곡 4 흰 테두리 |
| `AxisAddIconButton` | Button/Add Icon 130:9907 | `onPressed*, tooltip = '추가'`. 36px 연파랑 원 + |
| `AxisHelpfulButton` | Button/Helpful 130:9910 | `count*, onPressed*, selected = false, label = '도움돼요'` |
| `AxisDirectionsButton` | Button/Directions 130:9920 | `label = '길찾기', onPressed*` |
| `AxisIconButton` | Button/Icon Back·Share·Bookmark 130:9916/9918/9973 | `icon*: KitIcon, onPressed*, tooltip*, floating = false (흰 원+그림자), color, iconSize = 24`. `AxisIconButton.back({onPressed, floating})` |
| `AxisCloseButton` | Button/Close 130:9213 | `onPressed (없으면 maybePop), color`. 보이는 32, 탭 44 |
| `PressBuilder` | — | `builder*: (context, pressed) → Widget, onTap, semanticLabel, scale = 0.98`. 눌림 색이 필요한 새 버튼용 |
| `BrandButton`, `OutlineButton`, `SecondaryButton`, `TextLinkButton`, `Pressable` | (기존) | 예전 그라디언트 버튼·Button/Text. 새 화면의 메인 CTA는 `AxisCtaButton` |

규칙: 작은 버튼·칩 굴곡 8, 상태 태그 굴곡 4, 메인 CTA는 사선 컷, 떠 있는 보조 행동은 완전한 알약형.

## 선택 (selection.dart, + 기존 form_widgets.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisToggle` | Toggle 130:9834 | `value*, onChanged*: ValueChanged<bool>?, semanticLabel`. 48×28 |
| `AxisChip` | Chip 130:9287 | `label*, selected*, onTap*, expand = false`. 최소 높이 44, 13pt |
| `AxisRadio` | Radio 130:9373 | `selected*`. 20px (누름 처리는 감싸는 쪽에서) |
| `AxisColorSwatch` | ColorSwatch 130:9369 | `color*, selected*, onTap, size = 16` (탭 영역 6px 여유) |
| `AxisStepper` | Stepper 130:9378 | `value*` ("40분"), `onMinus*, onPlus*` (null이면 흐림), `caption` |
| `AxisCheckbox`, `ConsentRow`, `OptionBox`, `AxisTextField`, `AxisSelectField` | Checkbox / Agreement / MBTI Option / TextField (기존 form_widgets.dart) | 그대로 사용 |

## 목록·설정 (rows.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisSettingRow` | Setting Row/Basic 130:9848, /Description 130:9844 | `title*, description, value, onChanged, trailing, onTap`. `value`+`onChanged` → 오른쪽 토글(줄 전체 탭으로도 토글). 최소 높이 60/72 |
| `AxisMenuRow` | List/Menu Row 130:10244 | `label*, onTap*, icon (KitIcon.menu*), value (회색 값), showChevron = true`. 최소 56, 눌림 #F4F5FA |
| `AxisCategoryRow` | List/Category Row 130:10034 | `color*, title*, subtitle*, percent* (0~100), onTap (있으면 ›)`. 아래 1px 선 |
| `AxisGroupLabel(text*)` | 설정 그룹 라벨 | 12 SemiBold gray06, 위 24·아래 4 |
| `AxisSectionTitle(text*, trailing)` | 섹션 제목 | 20 Bold |
| `AxisDivider(indent = 0)` | 1px #EDEEF6 | |
| `AxisSectionDivider()` | Divider/Section 130:9839 | 8px #F4F5FA 띠(가로 끝까지 — 좌우 여백 밖에 둘 것) |

목록 규칙: 줄 위아래 16, 제목 16 SemiBold, 보조 12 Regular gray06, 구분선 1px #EDEEF6.

## 카드 (cards.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisCategoryCard` | Card/Category 130:9851 | `title*, days*: List<bool> (날마다 실천 여부), color = brand, periodLabel = '이번 달', onTap`. "18/30일"은 자동 계산 |
| `AxisTemplateInfo` | Card/Template Info 130:10097 | `title*, description, meta ("3달 소요"), footnote ("댓글 99+ · 작성자")` |
| `AxisMetaChip(label*, icon = KitIcon.clockSmall)` | Meta/Duration | 회색 굴곡 4 칩 |

## 세그먼트 (segmented.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisSegmentedTabs` | Segmented/List Map 130:10156, Segmented/Tab 3 130:10169 | `labels*: List<String>, selected*: int, onChanged*: ValueChanged<int>`. 회색 바탕 + 사선 흰 표시가 미끄러짐, 높이 40, 가로 꽉 |
| `AxisPillSegment` | Segmented/Tab 2 130:9937 | 같은 파라미터. 사진·어두운 배경 위 반투명 알약, 선택 칸 흰 바탕 |

## 캘린더 (calendar.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisWeekdayHeader` | Calendar/Weekdays 130:9922 | `highlight: int? (0=일), labels = 일~토` |
| `AxisMonthHeader` | Calendar/Month Header 130:10071 | `title*` ("2026년 11월"), `onPrev, onNext` (null이면 흐림) |
| `AxisCalendarDay` | Calendar/Day 130:10110 | `day*, state*: AxisDayState, size = 40, onTap`. 상태: `inProgress`(테두리+사선) `done`(채움) `scheduled`(테두리) `today`(파란 숫자) `empty`(회색 숫자) |
| `AxisDayLegendItem` | Coachmark/Legend Item 130:10123 | `state*, label*, description*, day = 8` |
| `AxisScheduleDayHeader` | Header/Schedule Day 130:10089 | `title*, countLabel, jMode: bool? (null=숨김), onJModeTap, filterLabel (null=숨김), onFilterTap` |

## 타임라인 (timeline.dart)

왼쪽 시간 칸 60 · 표시 25 · 내용(아래 1px 선) 구조.

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisTimelineMarker` | Timeline/Marker 130:9964 | `number*, state = AxisMarkerState.normal` (`normal current upcoming done`) |
| `AxisTimelinePlaceRow` | Timeline/Place Row 130:10042 | `time*, number*, title*, place, subtitle, state, onTap` |
| `AxisTimelineTransitRow` | Timeline/Transit Row 130:10050 | `duration*` ("15분 소요\n3.5km"), `mode*` ("지하철"), `icon = KitIcon.subway, route, detail, onTap` |
| `AxisTimelineStartRow` | Timeline/Start Row 130:10060 | `time*, title*` ("집"), `place, prepLabel = '준비 설정 시간', prepValue` ("20분", 빨강 강조), `onTap` |

## 진행·로딩 (progress.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisMiniBar` | Progress/Mini Bar 130:10265 | `value*` (0~1), `width = 64, color = brand`. 높이 4 |
| `AxisStepBar` | Progress/Step Bar 130:10078 | `total*, done*, doneColor = brandStep, todoColor = 흰 12%` (흰 화면에서는 `todoColor: AppColors.gray02`) |
| `AxisStepItem` | Progress/Step Item 130:10200 | `label*, state*: AxisStepState (done/now/todo)`. 어두운 바탕용, now는 도는 고리 |
| `AxisSkeletonBar` | Skeleton/Bar 130:9996 | `width = 120 (null이면 부모 제약을 따름), height = 14`. 깜빡임 반복 |
| `AxisPager` | Pager 130:10238 | `page*` (1부터), `count*, onChanged*` |

## 배지 (badges.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisTag(label*, tone = AxisTagTone.blue)` | Badge/Tag 130:10301 | tone: `red green blue orange gray neutral dark` |
| `AxisEventStatusBadge(status*)` | Badge/Event Status 130:10231 | `AxisEventStatus.joined`(참여 중) `.join`(참여하기) `.done`(참여 완료) |
| `AxisHeroPill(label*, muted = false)` | Badge/Hero Pill 130:10318 | 검정 알약 "7일 남음" |
| `AxisNumberBadge(number*, blue = false)` | Badge/Number 130:10325 | 20px 원 |
| `AxisRankBadge(rank*, top = false)` | Badge/Rank 130:10332 | 카드 왼쪽 위 꼬리표 |
| `AxisNotificationBadge(count)` | Badge/Notification 130:10337 | count 없으면 "N" |
| `AxisCompareBadge(after*, label)` | Badge/Compare 130:10342 | Before 회색 / After 파랑 |
| `AxisMedalImage(medal*, size = 70)` | Badge/Medal 130:10347 | `AxisMedal.awakening primeAxis flowCenter firstStep coordSharer shareSprout dawnAxis focusOrbit perfectWeek` (`.title`=한글 이름) |
| `AxisBadgeItem(medal*, caption*, progress, name)` | Badge/Item 130:10286 | `progress` 있으면 잠김(40% + 자물쇠 + 미니 바) |

## 그림 (media.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisAvatar(character* 1~12, size = 60, selected = false, onTap)` | Avatar/Character 130:9997 | 선택 시 파란 2px 테두리. `AxisAvatar.asset(n)`으로 경로 |
| `AxisEventIcon(type*, size = 40)` | Icon/Event 130:10220 | `AxisEventIconType.attendance planKing affirmation invite badge` (3D 메탈) |
| `AxisAiOrb(size = 80, pulse = false)` | AI/Orb 130:10215 | `size`=구슬 지름, 빛은 2.5배로 넘쳐 그려짐(레이아웃은 size만) |
| `AxisMapPin(number, color = CubeColors.green, home = false, size = 24)` | Map/Pin 130:10194 | 번호 핀 / 집 핀 |

## 상태 (states.dart)

| 위젯 | 피그마 | 파라미터 |
|---|---|---|
| `AxisEmptyState` | State/Empty 130:9988 | `title*, description, icon = KitIcon.navBookmark, actionLabel, onAction` |
| `AxisCoachmarkBottomBar` | Coachmark/Bottom Bar 130:10149 | `dontShowAgain*, onDontShowAgainChanged*, onClose*, checkLabel = '다시 보지 않기', closeLabel = '닫기'` (어두운 덮개 위) |

## 대화상자·토스트·시트 (dialogs.dart, sheets.dart)

```dart
final ok = await showAxisConfirm(context,
    title: '일정을 삭제할까요?', message: '삭제한 일정은 되돌릴 수 없어요.',
    confirmLabel: '이 일정만 삭제', otherLabel: '이후 일정 삭제', destructive: true);
// true = confirmLabel, false = otherLabel, null = X·바깥

showAxisToast(context, '저장했어요', actionLabel: '보기', onAction: () {}, bottom: 82);
hideAxisToast();

final v = await showAxisSheet<int>(context,
    title: '평소 준비시간', // ai: true → 파란 그라디언트 제목, onMore: → ⋯ 버튼
    builder: (ctx) => ...,               // 내용(넘치면 스크롤)
    footer: (ctx) => AxisCtaButton(label: '확인', onPressed: () => Navigator.pop(ctx, 40)));
```

| 위젯/함수 | 피그마 | 파라미터 |
|---|---|---|
| `showAxisConfirm(context, title*, message, confirmLabel*, otherLabel = '취소', destructive = true)` → `Future<bool?>` | Dialog/Confirm 130:9948 | destructive: 왼쪽 빨강 채움=confirm, 오른쪽 빨강 테두리=other. 아니면 왼쪽 회색=other, 오른쪽 파랑=confirm |
| `AxisConfirmDialog(title*, message, confirmLabel*, otherLabel*, destructive = true, onConfirm*, onOther*, onClose)` | 〃 | 직접 배치용(폭 320) |
| `showAxisToast(context, message*, actionLabel, onAction, duration = 2초, bottom = 24)` / `hideAxisToast()` | Toast 130:10255 | 루트 Overlay, 하나만 표시 |
| `AxisToast(message*, actionLabel, onAction, showCheck = true)` | 〃 | 직접 배치용 |
| `showAxisSheet<T>(context, title, ai = false, onMore, builder*, footer, isDismissible = true)` → `Future<T?>` | Sheet/Header 계열 | 위 굴곡 16, 높이 내용에 맞춤(최대 90%), 키보드만큼 올라감 |
| `AxisSheetHeader(title*, onClose, onMore, ai = false)` | Sheet/Header 130:9841, + More 130:9891, AI 130:9896 | |
| `AxisSheetFrame(header, child*, footer)` | — | 시트 틀만 필요할 때 |

## 도형 도우미 (shapes.dart)

`roundedPolygon(points, radii)` → `Path`(꼭짓점별 굴곡), `PolygonPainter(build*, fill, stroke, strokeWidth = 1, shadow)` — 사선 모양 새로 만들 때.

## 만들지 않은 것

- `Status Bar`(130:9392): OS가 그린다. 화면에서는 `AnnotatedRegion(value: lightScreenOverlay)`.
- `Button/Social`(130:9215), `MBTI Option`, `Agreement`, `TextField`, `Checkbox`: 기존 화면·form_widgets.dart에 이미 있음.
- `Badge/Hero Pill`의 Status·Status Muted 변형은 피그마에서 숨겨져 있어 `muted`(반투명)만 근사.
- `Icon/Small/Bookmark·Like`의 56×30 묶음 상자는 아이콘(`smallBookmark*`, `smallLike*`)만 제공.
