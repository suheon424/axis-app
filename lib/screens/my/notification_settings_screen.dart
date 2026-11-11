import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_widgets.dart';

/// 12-7 알림 설정(130:14020): 전체 알림 + 일정·커뮤니티·이벤트·혜택·방해 금지 그룹 토글.
/// 전체 알림을 끄면 나머지도 모두 꺼지고, 하나라도 켜면 전체 알림이 다시 켜진다.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _Item {
  const _Item(this.key, this.title, [this.description]);

  final String key;
  final String title;
  final String? description;
}

const _groups = <String, List<_Item>>{
  '일정': [
    _Item('before', '일정 시작 전 알림', '10분 전에 알려드려요'),
    _Item('ai', '틀어진 일정 AI 제안', '일정이 밀리면 다시 맞출 방법을 알려줘요'),
    _Item('report', '하루 마무리 리포트', '매일 09:00 PM'),
  ],
  '커뮤니티': [_Item('comment', '내 게시물 댓글'), _Item('like', '좋아요'), _Item('bookmark', '북마크')],
  '이벤트 · 혜택': [_Item('ad', '혜택 정보 수신 (광고성)')],
  '방해 금지': [_Item('dnd', '방해 금지 시간', '11:00 PM – 07:00 AM')],
};

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _on = <String, bool>{
    'before': true,
    'ai': true,
    'report': true,
    'comment': true,
    'like': false,
    'bookmark': false,
    'ad': false,
    'dnd': true,
  };
  String _adDate = '2026.03.14';

  bool get _all => _on.entries.any((e) => e.key != 'dnd' && e.value);

  void _setAll(bool v) => setState(() {
    for (final k in _on.keys) {
      if (k != 'dnd') _on[k] = v;
    }
  });

  void _set(String key, bool v) {
    setState(() {
      _on[key] = v;
      if (key == 'ad') _adDate = '2026.11.23';
    });
    if (key == 'ad') showAxisToast(context, v ? '혜택 정보 수신에 동의했어요' : '혜택 정보 수신을 거부했어요');
  }

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: '알림 설정',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: AxisSettingRow(title: '전체 알림', value: _all, onChanged: _setAll),
          ),
          for (final g in _groups.entries) ...[
            const AxisSectionDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AxisGroupLabel(g.key),
                  for (final item in g.value)
                    AxisSettingRow(
                      title: item.title,
                      description: item.key == 'ad' ? '$_adDate 수신 ${_on['ad']! ? '동의' : '거부'}' : item.description,
                      value: _on[item.key],
                      onChanged: (v) => _set(item.key, v),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
