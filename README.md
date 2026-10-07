# axis 플래너 (Flutter)

Figma 「클로드 개발」 파일의 화면 01~09를 Flutter(iOS · Android)로 옮긴 앱입니다.

## 실행

```bash
flutter pub get
flutter run            # 연결된 iPhone/Android 기기나 시뮬레이터에서 실행
flutter test           # 화면 이동 테스트
```

## 화면 흐름

| Figma 프레임 | 코드 | 이동 |
| --- | --- | --- |
| 01 첫 화면 | `lib/screens/welcome_screen.dart` | 가입하기 → 04, 이메일로 로그인 하기 → 02 |
| 02 / 03 로그인 (빈 상태 / 입력 상태) | `lib/screens/login_screen.dart` | 입력하면 밑줄·버튼이 03 상태로 바뀜, 회원가입 → 04 |
| 04 회원가입 | `lib/screens/signup_screen.dart` | 회원가입 하기 → 05 |
| 05 / 08 추가 정보 | `lib/screens/profile_setup_screen.dart` | 준비시간 → 06, 주소 → 07, mbti → 09 |
| 06 준비시간 선택 시트 | `lib/screens/selection_sheets.dart` | 칩 선택 후 시작하기 → 05에 값 표시 |
| 07 위치 찾기 | `lib/screens/address_search_screen.dart` | 검색어 입력 후 돋보기·완료 → 05에 값 표시 (음성 검색, 내위치, 지도에서 찾기는 준비 중 안내) |
| 09 MBTI 선택 시트 | `lib/screens/selection_sheets.dart` | 칩 선택 후 시작하기 → 05에 값 표시 |

Figma 프로토타입에는 각 화면 왼쪽 위 화살표의 "뒤로" 동작만 연결되어 있어서, 나머지 이동은 버튼 문구를 기준으로 연결했습니다.

## 애니메이션

- 화면 이동: 오른쪽에서 밀려 들어오는 iOS 방식(두 플랫폼 동일), 스와이프로 뒤로가기
- 첫 화면: 로고와 버튼이 차례로 떠오르며 등장
- 입력창: 포커스·입력 시 밑줄 굵기와 색이 파란색으로 전환
- 버튼: 누를 때 살짝 줄어듦, 로그인 버튼은 입력이 채워지면 회색 → 그라디언트
- 바텀시트(06, 09): 아래에서 올라오고 아래로 끌어 닫기, 칩 선택 시 색 전환
- 약관 체크박스: 체크 표시가 튀어나오듯 등장
