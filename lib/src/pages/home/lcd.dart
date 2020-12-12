import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:lcd/lcd.dart';

import '../../repositories/systems/models/models.dart';

class LcdWidget extends StatelessWidget {
  const LcdWidget({
    Key key,
    @required this.config,
    @required this.system,
  })  : assert(config != null),
        assert(system != null),
        super(key: key);

  final LcdModel config;
  final Device system;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ScopedReader watch, Widget child) {
        final StateNotifier<LcdEvent> lcdEvent =
            watch(lcdNotifierFamily(system.memoryReader));

        return Positioned(
          left: config.left,
          top: config.top,
          child: Stack(
            children: <Widget>[
              Container(
                height: config.height,
                width: config.width,
                color: Color(config.colors.background),
              ),
              Positioned(
                left: config.offsets.horizontal,
                top: config.offsets.vertical,
                child: SizedBox(
                  width: config.width - (config.offsets.horizontal * 2),
                  height: config.height - (config.offsets.vertical * 2),
                  child: CustomPaint(painter: _Screen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Screen extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = const Color(0xFF666052);
    final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
