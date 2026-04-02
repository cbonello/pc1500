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
      final String? path = call.arguments as String?;
      if (path == null) return;
      switch (call.method) {
        case 'screenshot':
          await _takeScreenshot(path);
        case 'saveStateTo':
          final DeviceRepository repo = ref.read(deviceRepositoryProvider);
          await repo.saveStateTo(path);
        case 'restoreStateFrom':
          final DeviceRepository repo = ref.read(deviceRepositoryProvider);
          await repo.restoreStateFrom(path);
      }
    });
  }

  void _requestScreenshot() {
    _toolbarChannel.invokeMethod<void>('requestScreenshot');
  }

  void _requestSaveState() {
    _toolbarChannel.invokeMethod<void>('requestSaveState');
  }

  void _requestRestoreState() {
    _toolbarChannel.invokeMethod<void>('requestRestoreState');
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

    try {
      await File(path).writeAsBytes(byteData.buffer.asUint8List());
    } on FileSystemException catch (_) {
      // Permission denied or invalid path — silently ignore.
    }
  }

  Future<void> _openDoc(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final String fileName = assetPath.split('/').last;
      final Directory tempDir = Directory.systemTemp;
      final File tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(data.buffer.asUint8List());
      await Process.run('open', <String>[tempFile.path]);
    } on Object catch (_) {
      // Asset not found or write failed — silently ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SystemsRepository> systemsRepository = ref.watch(
      systemsRepositoryProvider,
    );
    final DeviceRepository deviceRepository = ref.watch(
      deviceRepositoryProvider,
    );

    return PlatformMenuBar(
      menus: _buildMenus(deviceRepository),
      child: Scaffold(
        backgroundColor: const Color(0xFFBABEC1),
        body: systemsRepository.when<Widget>(
          data: (SystemsRepository repository) {
            final SkinModel skin = repository.getSkin(deviceRepository.type);
            final LcdWidget lcd = LcdWidget(
              config: skin.lcd,
              eventsStream: deviceRepository.device.lcdEvents,
            );

            return Column(
              children: <Widget>[
                Expanded(
                  child: RepaintBoundary(
                    key: _skinKey,
                    child: Skin(
                      skin: skin,
                      lcd: lcd,
                      device: deviceRepository.device,
                      onScreenshot: _requestScreenshot,
                    ),
                  ),
                ),
                _StatusBar(deviceRepository: deviceRepository),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object err, StackTrace _) =>
              Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  List<PlatformMenu> _buildMenus(DeviceRepository deviceRepository) {
    final DeviceType currentType = deviceRepository.type;

    return <PlatformMenu>[
      // ── App menu (About, Quit, etc.) ──
      const PlatformMenu(
        label: 'pc1500',
        menus: <PlatformMenuItem>[
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.about,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.servicesSubmenu,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.hide,
              ),
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.hideOtherApplications,
              ),
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.showAllApplications,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit,
              ),
            ],
          ),
        ],
      ),

      // ── File ──
      PlatformMenu(
        label: 'File',
        menus: <PlatformMenuItem>[
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformMenuItem(
                label: 'Save State...',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyS,
                  meta: true,
                ),
                onSelected: _requestSaveState,
              ),
              PlatformMenuItem(
                label: 'Restore State...',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyO,
                  meta: true,
                ),
                onSelected: _requestRestoreState,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformMenuItem(
                label: 'Screenshot...',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyS,
                  meta: true,
                  shift: true,
                ),
                onSelected: _requestScreenshot,
              ),
            ],
          ),
        ],
      ),

      // ── Hardware ──
      PlatformMenu(
        label: 'Hardware',
        menus: <PlatformMenuItem>[
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformMenuItem(
                label: currentType == DeviceType.pc1500
                    ? '\u2713 PC-1500'
                    : '    PC-1500',
                onSelected: () =>
                    _switchDevice(deviceRepository, DeviceType.pc1500),
              ),
              PlatformMenuItem(
                label: currentType == DeviceType.pc1500A
                    ? '\u2713 PC-1500A'
                    : '    PC-1500A',
                onSelected: () =>
                    _switchDevice(deviceRepository, DeviceType.pc1500A),
              ),
              PlatformMenuItem(
                label: currentType == DeviceType.pc2
                    ? '\u2713 PC-2'
                    : '    PC-2',
                onSelected: () =>
                    _switchDevice(deviceRepository, DeviceType.pc2),
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformMenuItem(
                label: 'Reset (Cold Boot)',
                onSelected: () => deviceRepository.coldReset(),
              ),
            ],
          ),
        ],
      ),

      // ── Help ──
      PlatformMenu(
        label: 'Help',
        menus: <PlatformMenuItem>[
          PlatformMenuItem(
            label: 'PC-2 User Manual',
            onSelected: () => _openDoc('assets/docs/PC2_Manual.pdf'),
          ),
          PlatformMenuItem(
            label: 'PC-1500 Technical Reference Manual',
            onSelected: () =>
                _openDoc('assets/docs/PC1500_Technical_reference_manual.pdf'),
          ),
        ],
      ),

      // View and Window menus are defined in MainMenu.xib with native
      // macOS selectors (toggleFullScreen:, performMiniaturize:, etc.).
    ];
  }

  void _switchDevice(DeviceRepository repo, DeviceType newType) {
    if (repo.type == newType) return;

    if (!repo.canSafelySwitchTo(newType)) {
      showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: const Text('Switch Hardware'),
          content: const Text(
            'Switching to a different RAM size will clear the current '
            'BASIC program. Continue?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Switch'),
            ),
          ],
        ),
      ).then((bool? confirmed) {
        if (confirmed == true) {
          repo.type = newType;
        }
      });
    } else {
      repo.type = newType;
    }
  }
}

/// A thin black status bar below the emulator skin showing device info.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.deviceRepository});

  final DeviceRepository deviceRepository;

  String get _deviceLabel => switch (deviceRepository.type) {
    DeviceType.pc1500 => 'PC-1500',
    DeviceType.pc1500A => 'PC-1500A',
    DeviceType.pc2 => 'PC-2',
  };

  String get _ramLabel => switch (deviceRepository.type) {
    DeviceType.pc1500 || DeviceType.pc2 => '2KB RAM',
    DeviceType.pc1500A => '6KB RAM',
  };

  @override
  Widget build(BuildContext context) {
    final bool debugConnected = deviceRepository.device.isDebugClientConnected;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFBABEC1),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 11,
          fontFamily: 'monospace',
        ),
        child: Row(
          children: <Widget>[
            Text(_deviceLabel),
            const SizedBox(width: 16),
            Text(_ramLabel),
            if (debugConnected) ...<Widget>[
              const SizedBox(width: 16),
              const Text('DBG'),
            ],
          ],
        ),
      ),
    );
  }
}
