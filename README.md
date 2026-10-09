# axis 플래너 (Flutter)

Figma 「클로드 개발」 파일의 화면 01~06을 Flutter(iOS · Android)로 옮긴 앱입니다.

## 실행

```bash
flutter pub get
flutter run            # 연결된 iPhone/Android 기기나 시뮬레이터에서 실행
flutter test           # 화면 이동 테스트
./tool/build_web.sh    # GitHub Pages용 웹 빌드(build/web)
```

웹 테스트 링크(https://suheon424.github.io/axis-app/)는 `build/web` 내용을 `gh-pages` 브랜치에 올려 배포합니다.
`web/sw.js`가 한 번 받은 앱 파일을 휴대폰에 저장해 두어, 홈 화면에 추가한 앱이 두 번째부터 빨리 열립니다.
빌드 스크립트가 배포마다 새 빌드 번호를 넣으므로 새 버전을 올리면 저장된 파일도 바뀝니다.

## 화면 흐름

| Figma 프레임 | 코드 | 이동 |
| --- | --- | --- |
| 01 첫 화면 | `lib/screens/welcome_screen.dart` | 가입하기 → 04, 이메일로 로그인 하기 → 02 |
| 02 / 03 로그인 | `lib/screens/login_screen.dart` | 두 칸을 채우면 로그인 버튼 활성화, 회원가입 → 04 |
| 04 회원가입 | `lib/screens/signup_screen.dart` | 네 칸과 필수 약관을 채우면 가입하기 → 05 (칸을 벗어나면 형식 오류 안내) |
| 05 기본 정보 | `lib/screens/profile_setup_screen.dart` | 준비시간 → 5-1, 집 주소 → 5-3, MBTI → 5-2, 시작하기·나중에 입력할게요 → 06 |
| 5-1 준비시간 시트 | `lib/screens/selection_sheets.dart` | 10분 단위 조절 또는 자주 쓰는 시간 선택 후 선택 완료 |
| 5-2 MBTI 시트 | `lib/screens/selection_sheets.dart` | 네 가지 축을 모두 고르면 선택 완료, 잘 모르겠어요로 건너뛰기 |
| 5-3 주소 검색 | `lib/screens/address_search_screen.dart` | 검색 요령 안내, 입력하면 관련 주소 목록, 고르면 상세 주소 입력으로 |
| 5-3 상세 주소 입력 | `lib/screens/address_detail_screen.dart` | 동·호수를 붙여 이 주소로 등록 → 05에 값 표시 |
| 06 프로필 캐릭터 | `lib/screens/character_screen.dart` | 배경색 8가지·캐릭터 12종 선택, 시작하기 → 홈 |

Figma 프로토타입에는 각 화면 왼쪽 위 화살표의 "뒤로" 동작만 연결되어 있어서, 나머지 이동은 버튼 문구를 기준으로 연결했습니다.

## 애니메이션

- 화면 이동: 오른쪽에서 밀려 들어오는 iOS 방식(두 플랫폼 동일), 스와이프로 뒤로가기
- 첫 화면: 로고와 버튼이 차례로 떠오르며 등장
- 입력창: 포커스·입력 시 밑줄 굵기와 색이 파란색으로 전환
- 버튼: 누를 때 살짝 줄어듦, 로그인 버튼은 입력이 채워지면 회색 → 그라디언트
- 바텀시트(5-1, 5-2): 아래에서 올라오고 아래로 끌어 닫기, 선택 시 색 전환
- 캐릭터 미리보기: 캐릭터를 바꾸면 살짝 떠오르며 교체, 배경색은 부드럽게 전환
- 약관 체크박스: 체크 표시가 튀어나오듯 등장
