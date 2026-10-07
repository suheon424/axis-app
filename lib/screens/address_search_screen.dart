import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_widgets.dart';

/// 07 · 집 주소 입력 화면. 입력 후 완료(키보드의 완료 버튼)하면 이전 화면으로 주소를 돌려준다.
class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key, this.initial});

  final String? initial;

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    Navigator.of(context).pop(value.trim());
  }

  void _useCurrentLocation() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('현재 위치 찾기는 위치 권한 연동 후 사용할 수 있어요.')));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.searchBg,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 53),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 16),
                child: Row(
                  children: [
                    const BackArrowButton(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: AppSizes.buttonHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.searchBorder),
                        ),
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: _submit,
                          style: const TextStyle(fontSize: 14, color: AppColors.gray07),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: '주소를 입력해 주세요',
                            hintStyle: TextStyle(fontSize: 14, color: AppColors.hint.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: BrandButton(
                  label: '현재 위치로 찾기',
                  fontSize: 18.68,
                  fontWeight: FontWeight.w600,
                  onPressed: _useCurrentLocation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
