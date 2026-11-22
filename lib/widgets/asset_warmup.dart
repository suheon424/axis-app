import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/main/home_spline_cube.dart' show onMobileDevice, prewarmSplineCube, splineWarmHost;

/// 앱이 뜬 뒤 그림 파일을 미리 받아 풀어 둔다(웹·실제 앱 모두).
/// 웹은 그림을 처음 보여 줄 때 서버에서 받아 오느라 화면이 바뀔 때 그림이 늦게 뜨고 버벅인다.
/// 첫 화면이 그려지고 잠시 뒤부터 하나씩(사이사이 쉬면서) 받아 두면 이후 화면은 바로 그려진다.
/// 움직이는 GIF(배지 획득 팝업, AI 플래너 소개)가 크고 늦게 떠서 가장 먼저 받는다.
class AssetWarmup extends StatefulWidget {
  const AssetWarmup({super.key, required this.child});

  final Widget child;

  @override
  State<AssetWarmup> createState() => _AssetWarmupState();
}

class _AssetWarmupState extends State<AssetWarmup> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // SVG 아이콘이 132개라 기본 캐시(100개)로는 화면을 옮길 때마다 밀려난 아이콘을 다시 풀어 버벅인다.
    svg.cache.maximumSize = 400;
    if (!kIsWeb) {
      // 실제 앱도 화면을 처음 열 때 그림·아이콘을 푸느라 전환이 끊긴다. 첫 화면 뒤에 미리 풀어 두고,
      // 큐브 장면도 미리 받아 둔다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        prewarmSplineCube();
        if (onMobileDevice) Timer(const Duration(milliseconds: 600), _run);
      });
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(milliseconds: 600), _run);
    });
  }

  Future<void> _run() async {
    final List<String> assets;
    try {
      assets = (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets();
    } catch (_) {
      return;
    }
    int rank(String p) => p.endsWith('.gif') ? 0 : (p.endsWith('.svg') ? 2 : 1);
    final list = assets.where((p) => p.startsWith('assets/images/') || p.startsWith('assets/icons/')).toList()
      ..sort((a, b) => rank(a).compareTo(rank(b)));
    for (final path in list) {
      if (!mounted) return;
      try {
        if (path.endsWith('.svg')) {
          final loader = SvgAssetLoader(path);
          await svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
        } else if (path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.gif')) {
          await precacheImage(AssetImage(path), context);
        }
      } catch (_) {
        // 미리 받기는 덤이라 실패해도 넘어간다.
      }
      // 화면 그리기와 겹치지 않게 한 프레임 쉰다.
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!onMobileDevice) return widget.child;
    // 큐브 웹뷰를 앱 화면 뒤에 잠깐 붙여 미리 그려 둔다(앱 화면이 덮고 있어 보이지 않는다).
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        Positioned.fill(child: splineWarmHost()),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}
