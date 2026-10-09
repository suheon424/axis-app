import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/address_suggestions.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_widgets.dart';

/// 5-3 · 상세 주소 입력. 고른 주소를 보여 주고 동·호수를 받아 '주소, 상세' 형태로 돌려준다.
class AddressDetailScreen extends StatefulWidget {
  const AddressDetailScreen({super.key, required this.suggestion});

  final AddressSuggestion suggestion;

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  final _detail = TextEditingController();

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  void _register() {
    final detail = _detail.text.trim();
    final address = widget.suggestion.address;
    Navigator.of(context).pop(detail.isEmpty ? address : '$address, $detail');
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final s = widget.suggestion;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 4),
                SizedBox(
                  height: AppSizes.navHeight,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      Text(
                        '상세 주소 입력',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray07),
                      ),
                      Positioned(left: 8, child: BackArrowButton(color: AppColors.gray07)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(AppSizes.sidePadding, 36, AppSizes.sidePadding, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.searchBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (s.name != s.address) ...[
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.body,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                s.address,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gray07,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Text(
                                  '주소 다시 검색',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AxisTextField(
                          label: '상세 주소 (선택)',
                          controller: _detail,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _register(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '동·호수 등 나머지 주소를 입력해 주세요.',
                          style: TextStyle(fontSize: 13, color: AppColors.caption),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.sidePadding,
                    0,
                    AppSizes.sidePadding,
                    safeBottom > 24 ? safeBottom : 24,
                  ),
                  child: BrandButton(label: '이 주소로 등록', onPressed: _register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
