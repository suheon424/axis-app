import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_widgets.dart';

/// 12-8 1:1 문의(130:13268): 문의하기·문의 내역 탭. 문의하기는 유형·제목·내용·사진 첨부 + 안내 + 문의 보내기.
/// 유형·제목·내용을 모두 채워야 버튼이 파랗게 켜지고, 보내면 문의 내역 탭에 쌓인다.
class InquiryScreen extends StatefulWidget {
  const InquiryScreen({super.key});

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _Inquiry {
  const _Inquiry(this.type, this.title, this.date, {this.answered = false});

  final String type;
  final String title;
  final String date;
  final bool answered;
}

class _InquiryScreenState extends State<InquiryScreen> {
  static const _types = ['일정 · AI 플래너', '이벤트 · 포인트', '커뮤니티', '계정 · 로그인', '기타'];

  int _tab = 0;
  String? _type;
  late final _title = TextEditingController()..addListener(_refresh);
  late final _content = TextEditingController()..addListener(_refresh);
  int _photos = 0;
  final _history = <_Inquiry>[const _Inquiry('일정 · AI 플래너', '반복 일정이 지도에 두 번 보여요', '2026.11.02', answered: true)];

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  bool get _ready => _type != null && _title.text.trim().isNotEmpty && _content.text.trim().isNotEmpty;

  Future<void> _pickType() async {
    final picked = await showAxisSheet<String>(
      context,
      title: '문의 유형',
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final t in _types)
              AxisMenuRow(
                label: t,
                showChevron: false,
                value: t == _type ? '선택됨' : null,
                onTap: () => Navigator.pop(ctx, t),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _type = picked);
  }

  void _send() {
    FocusScope.of(context).unfocus();
    setState(() {
      _history.insert(0, _Inquiry(_type!, _title.text.trim(), '2026.11.23'));
      _type = null;
      _title.clear();
      _content.clear();
      _photos = 0;
      _tab = 1;
    });
    showAxisToast(context, '문의를 보냈어요', bottom: 100);
  }

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: '1:1 문의',
      bottom: _tab == 0 ? AxisCtaButton(label: '문의 보내기', enabled: _ready, onPressed: _send) : null,
      body: Column(
        children: [
          AxisSegmentedTabs(
            labels: const ['문의하기', '문의 내역'],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          Expanded(child: _tab == 0 ? _form() : _historyList()),
        ],
      ),
    );
  }

  Widget _form() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        const Text('문의 유형', style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray06)),
        Semantics(
          button: true,
          label: '문의 유형 ${_type ?? '선택'}',
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickType,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.gray04)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _type ?? '유형을 선택해 주세요',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: -0.32,
                        color: _type == null ? AppColors.gray05 : AppColors.text,
                      ),
                    ),
                  ),
                  const RotatedBox(quarterTurns: 1, child: AxisChevronRight(color: AppColors.gray06)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        MyUnderlineField(label: '제목', controller: _title, hint: '제목을 입력해 주세요', clearable: true),
        const SizedBox(height: 28),
        MyUnderlineField(
          label: '내용',
          controller: _content,
          hint: '불편한 점이나 궁금한 점을 자세히 적어 주세요',
          maxLines: null,
          maxLength: 1000,
          counterBelow: true,
        ),
        const SizedBox(height: 28),
        Text('사진 첨부 $_photos/3', style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray06)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < _photos; i++) ...[
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: AppColors.gray02, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.image_outlined, color: AppColors.subIcon),
              ),
              const SizedBox(width: 8),
            ],
            if (_photos < 3) _AddPhotoBox(onTap: () => setState(() => _photos++)),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.gray01, borderRadius: BorderRadius.circular(8)),
          child: const Text(
            '답변은 평일 기준 1~2일 안에 알림으로 알려드려요.\n운영 시간: 평일 10:00 AM – 06:00 PM',
            style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.gray06),
          ),
        ),
      ],
    );
  }

  Widget _historyList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        for (final q in _history)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray02)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AxisTag(q.answered ? '답변 완료' : '답변 대기', tone: q.answered ? AxisTagTone.blue : AxisTagTone.gray),
                    const SizedBox(width: 6),
                    Text(q.type, style: AxisText.caption),
                  ],
                ),
                const SizedBox(height: 6),
                Text(q.title, style: AxisText.rowTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 4),
                Text(q.date, style: AxisText.caption),
              ],
            ),
          ),
      ],
    );
  }
}

/// 점선 테두리 76px "+ 추가" 상자.
class _AddPhotoBox extends StatelessWidget {
  const _AddPhotoBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '사진 추가',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedRectPainter(),
          child: const SizedBox(
            width: 76,
            height: 76,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AxisIcon(KitIcon.navPlus, color: AppColors.subIcon),
                SizedBox(height: 2),
                Text('추가', style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.gray06)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray04
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)));
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) => false;
}
