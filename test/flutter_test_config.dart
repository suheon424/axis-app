import 'dart:async';

import 'package:axis_app/widgets/kit/kit.dart';

/// 모든 테스트 공통: 끝없이 도는 AI 알약 선은 끈다(pumpAndSettle이 끝나도록).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AxisAiPill.spinEnabled = false;
  await testMain();
}
