/// 07 위치 찾기의 검색어 자동완성.
///
/// 아직 주소 검색 API(카카오 로컬, 도로명주소 API 등)를 연결하지 않아서 앱에 넣어 둔 예시 목록에서 찾는다.
/// API를 붙일 때는 [searchAddresses]만 바꾸면 화면은 그대로 쓸 수 있다.
class AddressSuggestion {
  const AddressSuggestion(this.name, this.address);

  /// 장소 이름. 도로명만 있는 항목은 도로명을 그대로 쓴다.
  final String name;

  /// 도로명 주소. 선택하면 이 값이 05 화면 주소 칸에 들어간다.
  final String address;
}

const _samples = <AddressSuggestion>[
  AddressSuggestion('한성대학교', '서울 성북구 삼선교로16길 116'),
  AddressSuggestion('성북구청', '서울 성북구 보문로 168'),
  AddressSuggestion('고려대학교', '서울 성북구 안암로 145'),
  AddressSuggestion('국민대학교', '서울 성북구 정릉로 77'),
  AddressSuggestion('성신여자대학교', '서울 성북구 보문로34다길 2'),
  AddressSuggestion('서울대학교', '서울 관악구 관악로 1'),
  AddressSuggestion('연세대학교', '서울 서대문구 연세로 50'),
  AddressSuggestion('홍익대학교', '서울 마포구 와우산로 94'),
  AddressSuggestion('서울역', '서울 용산구 한강대로 405'),
  AddressSuggestion('강남역', '서울 강남구 강남대로 396'),
  AddressSuggestion('서울시청', '서울 중구 세종대로 110'),
  AddressSuggestion('광화문광장', '서울 종로구 세종대로 172'),
  AddressSuggestion('경복궁', '서울 종로구 사직로 161'),
  AddressSuggestion('마로니에공원', '서울 종로구 대학로8길 1'),
  AddressSuggestion('동대문디자인플라자', '서울 중구 을지로 281'),
  AddressSuggestion('남산서울타워', '서울 용산구 남산공원길 105'),
  AddressSuggestion('국립중앙박물관', '서울 용산구 서빙고로 137'),
  AddressSuggestion('롯데월드타워', '서울 송파구 올림픽로 300'),
  AddressSuggestion('코엑스', '서울 강남구 영동대로 513'),
  AddressSuggestion('63빌딩', '서울 영등포구 63로 50'),
  AddressSuggestion('여의도한강공원', '서울 영등포구 여의동로 330'),
  AddressSuggestion('김포국제공항', '서울 강서구 하늘길 112'),
  AddressSuggestion('인천국제공항 제1여객터미널', '인천 중구 공항로 272'),
  AddressSuggestion('부산역', '부산 동구 중앙대로 206'),
  AddressSuggestion('삼선교로', '서울 성북구 삼선교로'),
  AddressSuggestion('보문로', '서울 성북구 보문로'),
  AddressSuggestion('대학로', '서울 종로구 대학로'),
  AddressSuggestion('세종대로', '서울 중구 세종대로'),
  AddressSuggestion('강남대로', '서울 강남구 강남대로'),
  AddressSuggestion('테헤란로', '서울 강남구 테헤란로'),
];

String _norm(String s) => s.replaceAll(RegExp(r'\s+'), '').toLowerCase();

/// 검색어와 관련 있는 순서로 최대 [limit]개를 돌려준다.
///
/// 이름이 똑같으면 가장 앞, 그다음 이름이 검색어로 시작하는 것, 주소가 검색어로 시작하는 것,
/// 이름에 들어 있는 것, 주소에 들어 있는 것, 띄어쓴 단어가 모두 들어 있는 것 순이다.
/// 같은 단계에서는 검색어가 앞쪽에 나올수록, 이름이 짧을수록 위에 둔다.
List<AddressSuggestion> searchAddresses(String query, {int limit = 10}) {
  final q = _norm(query);
  if (q.isEmpty) return const [];
  final tokens = query.trim().toLowerCase().split(RegExp(r'\s+'));

  final scored = <(AddressSuggestion, double)>[];
  for (final item in _samples) {
    final name = _norm(item.name);
    final address = _norm(item.address);
    double score;
    if (name == q) {
      score = 1000;
    } else if (name.startsWith(q)) {
      score = 800;
    } else if (address.startsWith(q)) {
      score = 700;
    } else if (name.contains(q)) {
      score = 600.0 - name.indexOf(q);
    } else if (address.contains(q)) {
      score = 400.0 - address.indexOf(q);
    } else if (tokens.every((t) => '$name $address'.contains(t))) {
      score = 200;
    } else {
      continue;
    }
    scored.add((item, score - item.name.length / 100));
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final (item, _) in scored.take(limit)) item];
}
