import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 꼭짓점마다 굴곡을 줄 수 있는 다각형 경로. 사선 버튼·세그먼트 표시에 쓴다.
/// [radii]는 [points]와 같은 순서(0이면 뾰족).
Path roundedPolygon(List<Offset> points, List<double> radii) {
  final path = Path();
  final n = points.length;
  for (var i = 0; i < n; i++) {
    final prev = points[(i - 1 + n) % n];
    final cur = points[i];
    final next = points[(i + 1) % n];
    final r = radii[i];
    if (r <= 0) {
      i == 0 ? path.moveTo(cur.dx, cur.dy) : path.lineTo(cur.dx, cur.dy);
      continue;
    }
    final toPrev = prev - cur;
    final toNext = next - cur;
    final a = cur + toPrev / toPrev.distance * math.min(r, toPrev.distance / 2);
    final b = cur + toNext / toNext.distance * math.min(r, toNext.distance / 2);
    i == 0 ? path.moveTo(a.dx, a.dy) : path.lineTo(a.dx, a.dy);
    path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
  }
  return path..close();
}

/// 채움·테두리로 그리는 다각형 하나.
class PolygonPainter extends CustomPainter {
  const PolygonPainter({required this.build, this.fill, this.stroke, this.strokeWidth = 1, this.shadow});

  final Path Function(Size size) build;
  final Color? fill;
  final Color? stroke;
  final double strokeWidth;
  final BoxShadow? shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final path = build(size);
    if (shadow != null) {
      canvas.drawPath(
        path.shift(shadow!.offset),
        Paint()
          ..color = shadow!.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow!.blurSigma),
      );
    }
    if (fill != null) canvas.drawPath(path, Paint()..color = fill!);
    if (stroke != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke!
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(PolygonPainter old) =>
      old.fill != fill || old.stroke != stroke || old.strokeWidth != strokeWidth || old.build != build;
}
