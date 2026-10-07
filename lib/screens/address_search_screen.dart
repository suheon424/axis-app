import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../widgets/buttons.dart';

/// 07 · 위치 찾기 화면. 검색창에 장소나 주소를 입력하고 검색(키보드 완료 또는 돋보기)하면
/// 이전 화면으로 주소를 돌려준다.
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

  void _submit([String? value]) {
    final text = (value ?? _controller.text).trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const divider = BorderSide(color: AppColors.gray03);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.searchBg,
        body: SafeArea(
          child: Column(
            children: [
              // 검색창: 뒤로 · 입력 · 음성 | 검색
              Container(
                height: 50,
                decoration: const BoxDecoration(border: Border(bottom: divider)),
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '뒤로',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: SvgPicture.asset(
                        'assets/icons/ic_arrow_left.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(AppColors.icon, BlendMode.srcIn),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _submit,
                        style: const TextStyle(fontSize: 16, color: AppColors.gray07),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: '장소, 주소 검색',
                          hintStyle: TextStyle(fontSize: 16, color: AppColors.gray07.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    _IconTap(
                      tooltip: '음성 검색',
                      asset: 'assets/icons/ic_mic.svg',
                      width: 17,
                      height: 18,
                      onTap: () => _notice('음성 검색은 준비 중이에요.'),
                    ),
                    Container(width: 1, height: 19, color: AppColors.gray03),
                    _IconTap(
                      tooltip: '검색',
                      asset: 'assets/icons/ic_search.svg',
                      width: 18,
                      height: 18,
                      onTap: _submit,
                    ),
                  ],
                ),
              ),
              // 내위치 · 지도에서 찾기
              Container(
                height: 40,
                decoration: const BoxDecoration(border: Border(bottom: divider)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QuickAction(
                      asset: 'assets/icons/ic_my_location.svg',
                      label: '내위치',
                      color: AppColors.primary,
                      onTap: () => _notice('내 위치 찾기는 위치 권한 연동 후 사용할 수 있어요.'),
                    ),
                    const SizedBox(width: 50),
                    _QuickAction(
                      asset: 'assets/icons/ic_map.svg',
                      label: '지도에서 찾기',
                      color: Colors.black,
                      onTap: () => _notice('지도에서 찾기는 준비 중이에요.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({
    required this.tooltip,
    required this.asset,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final String tooltip;
  final String asset;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: SvgPicture.asset(asset, width: width, height: height),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.asset,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String asset;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(asset, width: 15, height: 15),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}
