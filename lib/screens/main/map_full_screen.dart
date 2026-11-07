import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/kit/kit.dart';
import 'map_data.dart';

/// 07_09-1 지도 크게 보기. 작은 지도의 확대 버튼으로 연다.
/// 두 손가락으로 확대·이동하고, 아래 카드를 넘기면 해당 핀이 선택된다.
/// 선택된 카드나 핀을 다시 누르면 장소 상세 시트(Place Card 1_선택시)가 열린다.
class MapFullScreen extends StatefulWidget {
  const MapFullScreen({super.key, this.optimized = false, this.initialId});

  final bool optimized;
  final String? initialId;

  @override
  State<MapFullScreen> createState() => _MapFullScreenState();
}

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
      value: lightScreenOverlay.copyWith(statusBarColor: mapGround),
      child: Scaffold(
        backgroundColor: mapGround,
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
                    child: MapCanvas(
                      asset: 'assets/icons/map_base_big.svg',
                      size: const Size(390, 844),
                      pins: bigMapPins,
                      route: _plan.route,
                      day: _plan,
                      routeWidth: 4,
                      selectedId: _cards[_index].id,
                      onTapPin: _onTapPin,
                    ),
                  ),
                ),
              ),
            ),
            // 상단: 뒤로 · 날짜 칩 · 접기
            Positioned(
              left: 20,
              right: 20,
              top: pad.top + 11,
              child: Row(
                children: [
                  AxisIconButton.back(floating: true),
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
            // 하단: 내 위치 + 장소 카드
            Positioned(
              right: 20,
              bottom: bottom + 116 + 13,
              child: MapRoundButton(
                label: '처음 위치로',
                color: AppColors.brand,
                onTap: _recenter,
                child: SvgPicture.asset(
                  'assets/icons/map_locate.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 0,
              bottom: bottom,
              height: 116,
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
    const style = TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600, color: AppColors.gray07);
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [BoxShadow(color: Color(0x29000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: '23일(월)  '),
            TextSpan(
              text: '일정 $count건',
              style: style.copyWith(color: AppColors.brand),
            ),
          ],
        ),
        style: style,
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.brand : Colors.white, width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 14, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AxisNumberBadge(stop.number!),
                  const SizedBox(width: 8),
                  Text(stop.time ?? '', style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.gray06)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      stop.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AxisText.rowTitle.copyWith(fontWeight: FontWeight.w700, color: AppColors.gray07),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${stop.place} · ${stop.address}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AxisText.caption,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stop.cardMove ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AxisDirectionsButton(onPressed: () => showAxisToast(context, '${stop.place}까지 길찾기를 시작해요.')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
