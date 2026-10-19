import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_spline_cube_io.dart' if (dart.library.js_interop) 'home_spline_cube_web.dart' as platform;

/// Spline 3D 큐브 장면 주소.
///
/// Spline 편집기에서 Export → Code Export → Web(또는 "Spline Viewer")으로 내보낸
/// `.splinecode` 주소를 넣는다. 예: `https://prod.spline.design/<id>/scene.splinecode`.
/// 비워 두면 피그마에서 내보낸 큐브 그림만 보인다.
const splineSceneUrl = 'https://prod.spline.design/hI7lJEYTqGpciYeI/scene.splinecode';

/// 장면을 불러오기 전·불러오지 못했을 때 보이는 피그마 큐브 그림(07_02의 Rubik's cube).
const homeCubeImage = 'assets/images/main/home_cube.png';

/// 07_02 달성률의 큐브.
///
/// - [url]이 비었거나 장면을 띄울 수 없는 플랫폼이면 큐브 그림을 보여 준다.
/// - 웹: `<spline-viewer>` 웹 컴포넌트를 HtmlElementView로 띄운다.
/// - iOS·Android: webview_flutter로 같은 `<spline-viewer>`를 담은 HTML을 띄운다.
///
/// 큐브 위의 손가락(스와이프) 버튼은 큐브를 누르고 있는 동안 사라졌다가 손을 떼면 다시 나타난다.
class SplineCube extends StatefulWidget {
  const SplineCube({
    super.key,
    this.url = splineSceneUrl,
    this.imageSize = const Size(177, 186),
    this.imageOffset = const Offset(0, -8),
    this.fingerOffset = const Offset(0, 9.5),
  });

  final String url;

  /// 큐브 그림의 크기와 가운데에서 벗어난 정도(피그마 위치 기준).
  final Size imageSize;
  final Offset imageOffset;

  /// 손가락 버튼이 가운데에서 벗어난 정도.
  final Offset fingerOffset;

  static const fingerKey = Key('home_spline_finger');
  static const sceneKey = Key('home_spline_scene');
  static const imageKey = Key('home_spline_image');

  @override
  State<SplineCube> createState() => _SplineCubeState();
}

class _SplineCubeState extends State<SplineCube> {
  bool _pressed = false;
  bool _loaded = false;

  void _setPressed(bool v) {
    if (!mounted || _pressed == v) return;
    setState(() => _pressed = v);
  }

  void _onLoaded() {
    if (!mounted || _loaded) return;
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.url.isEmpty
        ? null
        : platform.buildSplineScene(url: widget.url, onLoaded: _onLoaded, onPressChanged: _setPressed);

    return Listener(
      // 그림·모바일 웹뷰에서 누름을 받는다. 웹의 장면은 DOM 요소가 직접 이벤트를 받으므로
      // platform 쪽에서 pointerdown/up을 알려 준다.
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 장면이 뜨기 전·실패했을 때 보이는 피그마 그림(장면은 배경이 투명이라 그 위에 얹는다).
          AnimatedOpacity(
            opacity: _loaded ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: Transform.translate(
                offset: widget.imageOffset,
                child: Image.asset(
                  homeCubeImage,
                  key: SplineCube.imageKey,
                  width: widget.imageSize.width,
                  height: widget.imageSize.height,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (scene != null) KeyedSubtree(key: SplineCube.sceneKey, child: scene),
          Center(
            child: Transform.translate(
              offset: widget.fingerOffset,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  key: SplineCube.fingerKey,
                  opacity: _pressed ? 0 : 1,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: const _FingerButton(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 60 원형(검정 60% + 흐림) 안의 스와이프 손가락 아이콘.
class _FingerButton extends StatelessWidget {
  const _FingerButton();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          color: const Color(0x99000000),
          child: SvgPicture.asset('assets/icons/home_ic_swipe.svg', width: 28, height: 28),
        ),
      ),
    );
  }
}
