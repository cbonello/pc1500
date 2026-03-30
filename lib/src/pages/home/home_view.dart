import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc1500/src/pages/home/lcd.dart';
import 'package:pc1500/src/pages/home/skin.dart';
import 'package:pc1500/src/repositories/repositories.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final GlobalKey _skinKey = GlobalKey();
  late final MethodChannel _toolbarChannel;

  @override
  void initState() {
    super.initState();
    _toolbarChannel = const MethodChannel('pc1500/toolbar');
    _toolbarChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'screenshot') {
        final String? path = call.arguments as String?;
        if (path != null) {
          await _takeScreenshot(path);
        }
      }
    });
  }

  void _requestScreenshot() {
    _toolbarChannel.invokeMethod<void>('requestScreenshot');
  }

  Future<void> _takeScreenshot(String path) async {
    final RenderRepaintBoundary? boundary =
        _skinKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) return;

    await File(path).writeAsBytes(byteData.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SystemsRepository> systemsRepository = ref.watch(
      systemsRepositoryProvider,
    );
    final DeviceRepository deviceRepository = ref.watch(
      deviceRepositoryProvider,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFBABEC1),
      body: systemsRepository.when<Widget>(
        data: (SystemsRepository repository) {
          final SkinModel skin = repository.getSkin(deviceRepository.type);
          final LcdWidget lcd = LcdWidget(
            config: skin.lcd,
            eventsStream: deviceRepository.device.lcdEvents,
          );

          return RepaintBoundary(
            key: _skinKey,
            child: Skin(
              skin: skin,
              lcd: lcd,
              device: deviceRepository.device,
              onScreenshot: _requestScreenshot,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace _) =>
            Center(child: Text('Error: $err')),
      ),
    );
  }
}
