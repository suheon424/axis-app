import 'package:flutter/material.dart';

/// 임시 자리. 담당 작업에서 피그마 화면으로 바꾼다.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, this.showCoachmarks = false});

  final bool showCoachmarks;

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('CalendarScreen')));
}
