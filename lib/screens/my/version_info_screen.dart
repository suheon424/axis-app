import 'package:flutter/material.dart';

import '../../widgets/kit/kit.dart';
import 'my_data.dart';
import 'my_widgets.dart';
import 'notice_screen.dart';

/// 12-9 버전 정보(130:13289): 앱 아이콘 + 현재 버전 + 최신 버전 태그 + 약관 메뉴 + 저작권.
class VersionInfoScreen extends StatelessWidget {
  const VersionInfoScreen({super.key});

  static const _docs = ['서비스 이용약관', '개인정보 처리방침', '위치기반 서비스 이용약관', '오픈소스 라이선스'];

  @override
  Widget build(BuildContext context) {
    return MySubScaffold(
      title: '버전 정보',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 26),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/my/app_icon.png',
                    width: 88,
                    height: 88,
                    semanticLabel: 'axis 앱 아이콘',
                  ),
                ),
                const SizedBox(height: 16),
                Text('axis', style: AxisText.sectionTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '현재 버전 '),
                      TextSpan(
                        text: MyProfile.appVersion,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.brand),
                      ),
                    ],
                  ),
                  style: AxisText.body.copyWith(color: AppColors.gray06),
                ),
                const SizedBox(height: 8),
                const AxisTag('최신 버전이에요'),
                const SizedBox(height: 32),
                const AxisSectionDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (var i = 0; i < _docs.length; i++) ...[
                        if (i > 0) const AxisDivider(),
                        AxisMenuRow(
                          label: _docs[i],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MyDocumentScreen(
                                title: _docs[i],
                                heading: _docs[i],
                                date: '시행일 2026.12.01',
                                body: '${_docs[i]} 전문은 정식 출시 때 이곳에 실려요.',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 24, bottom: MediaQuery.paddingOf(context).bottom + 24),
                child: Text('© 2026 axis. All rights reserved.', style: AxisText.caption),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
