import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import 'map_data.dart';

/// 07_09-1 지도 크게 보기. 작은 지도의 확대 버튼으로 연다.
/// 두 손가락으로 확대·이동하고, 아래 카드를 넘기면 해당 핀이 선택된다.
class MapFullScreen extends StatefulWidget {
  const MapFullScreen({super.key, this.optimized = false, this.initialId});

  final bool optimized;
  final String? initialId;

  @override
  State<MapFullScreen> createState() => _MapFullScreenState();
}

/// 크게 보기 지도(390×844) 위 핀 왼쪽 위 좌표.
const _bigPins = {
  'home': Offset(65, 185),
  's1': Offset(312, 227),
  's2': Offset(299, 219),
  's3': Offset(249, 205),
  's4': Offset(71, 542),
  's5': Offset(118, 488),
};

class _MapFullScreenState extends State<MapFullScreen> with SingleTickerProviderStateMixin {
  late final MapDay _plan = MapDay.of(optimized: widget.optimized);
  late final List<MapStop> _cards = _plan.numbered;
  late int _index = _initialIndex();
  late final PageController _pages = PageController(viewportFraction: 312 / 370, initialPage: _index);
  final _transform = TransformationController();
  late final AnimationController _reset = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))
    ..addListener(() => _transform.value = _resetAnim?.value ?? Matrix4.identity());
  Animation<Matrix4>? _resetAnim;

  int _initialIndex() {
    final i = _cards.indexWhere((s) => s.id == widget.initialId);
    return i < 0 ? 0 : i;
  }

  @override
  void dispose() {
    _pages.dispose();
    _transform.dispose();
    _reset.dispose();
    super.dispose();
  }

  void _recenter() {
    _resetAnim = Matrix4Tween(
      begin: _transform.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _reset, curve: Curves.easeOutCubic));
    _reset.forward(from: 0);
  }

  void _onTapPin(MapStop stop) {
    final i = _cards.indexWhere((s) => s.id == stop.id);
    if (i < 0 || i == _index) {
      showPlaceDetailSheet(context, stop);
      return;
    }
    _pages.animateToPage(i, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final bottom = pad.bottom > 0 ? pad.bottom : 20.0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightScreenOverlay.copyWith(statusBarColor: MapColors.ground),
      child: Scaffold(
        backgroundColor: MapColors.ground,
        body: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transform,
                minScale: 1,
                maxScale: 4,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 390,
                      height: 844,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(child: SvgPicture.asset('assets/icons/map_base_big.svg')),
                          Positioned(
                            left: 74,
                            top: 194,
                            child: SvgPicture.asset('assets/icons/map_route_big.svg', width: 250, height: 359),
                          ),
                          Positioned.fill(
                            child: MapPinLayer(
                              day: _plan,
                              pins: _bigPins,
                              selectedId: _cards[_index].id,
                              ringSize: 40,
                              onTapPin: _onTapPin,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 상단: 뒤로 · 날짜 칩 · 접기 / 내 위치
            Positioned(
              left: 20,
              right: 20,
              top: pad.top + 8,
              child: Row(
                children: [
                  MapRoundButton(
                    label: '뒤로',
                    onTap: () => Navigator.of(context).maybePop(),
                    child: SvgPicture.asset('assets/icons/map_back_round.svg', width: 22, height: 22),
                  ),
                  const Spacer(),
                  _DateChip(count: _cards.length),
                  const Spacer(),
                  MapRoundButton(
                    label: '지도 작게 보기',
                    onTap: () => Navigator.of(context).maybePop(),
                    child: SvgPicture.asset('assets/icons/map_collapse.svg', width: 20, height: 20),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: pad.top + 64,
              child: MapRoundButton(
                label: '처음 위치로',
                onTap: _recenter,
                child: SvgPicture.asset('assets/icons/map_locate.svg', width: 22, height: 22),
              ),
            ),
            // 하단: 페이지 표시 + 장소 카드
            Positioned(
              left: 26,
              bottom: bottom + 113 + 10,
              child: Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xBF1F2126), borderRadius: BorderRadius.circular(100)),
                child: Text(
                  '${_index + 1} / ${_cards.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 0,
              bottom: bottom,
              height: 113,
              child: PageView.builder(
                controller: _pages,
                padEnds: false,
                clipBehavior: Clip.none,
                itemCount: _cards.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _PlaceCard(
                    stop: _cards[i],
                    selected: i == _index,
                    onTap: () => showPlaceDetailSheet(context, _cards[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x29000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '11월 23일 (월)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: MapColors.textStrong),
          ),
          const SizedBox(width: 8),
          Text(
            '일정 $count건',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.stop, required this.selected, required this.onTap});

  final MapStop stop;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.primary : Colors.white, width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x29000000), blurRadius: 14, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MapBadge(stop: stop, size: 20, fontSize: 12, bold: true),
                  const SizedBox(width: 8),
                  Text(
                    stop.time ?? '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: MapColors.textSub),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      stop.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MapColors.textStrong),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${stop.place} · ${stop.address}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.body),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stop.cardMove ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _DirectionsButton(place: stop.place),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionsButton extends StatelessWidget {
  const _DirectionsButton({required this.place});

  final String place;

  @override
  Widget build(BuildContext context) {
    void go() {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$place까지 길찾기를 시작해요.')));
    }

    return Semantics(
      button: true,
      label: '길찾기',
      excludeSemantics: true,
      onTap: go,
      child: Pressable(
        onTap: go,
        scale: 0.94,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Text(
            '길찾기',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
