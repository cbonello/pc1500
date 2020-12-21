import 'package:device/device.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart' as windows;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../repositories/local_storage/local_storage.dart';
import '../../repositories/systems/models/models.dart';
import '../../repositories/systems/systems_repository.dart';
import 'lcd.dart';
import 'skin.dart';

const Color borderColor = Color(0xFF805306);

class HomeView extends ConsumerWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final AsyncValue<SystemsRepository> systemsRepository =
        watch(systemsRepositoryProvider);
    final DeviceTypeRepository deviceTypeRepository =
        watch(deviceTypeRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFBABEC1),
      body: windows.WindowBorder(
        color: borderColor,
        width: 1,
        child: Column(
          children: <Widget>[
            windows.WindowTitleBarBox(
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 20.0),
                  _DeviceMenu(),
                  Expanded(child: windows.MoveWindow()),
                  const WindowButtons()
                ],
              ),
            ),
            Center(
              child: systemsRepository.when<Widget>(
                data: (SystemsRepository repository) {
                  final Device device = Device(
                    type: deviceTypeRepository.deviceType,
                    debugPort: 3756,
                  );
                  final SkinModel skin = repository.getSkin(
                    deviceTypeRepository.deviceType,
                  );
                  final LcdWidget lcd = LcdWidget(
                    config: skin.lcd,
                    eventsStream: device.lcdEvents,
                  );

                  return Skin(skin: skin, lcd: lcd);
                },
                loading: () => const CircularProgressIndicator(),
                error: (Object err, StackTrace _) => Text('Error: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const Color backgroundStartColor = Color(0xFFFFD500);
const Color backgroundEndColor = Color(0xFFF6A00C);

const windows.WindowButtonColors buttonColors = windows.WindowButtonColors(
    iconNormal: Color(0xFF805306),
    mouseOver: Color(0xFFF6A00C),
    mouseDown: Color(0xFF805306),
    iconMouseOver: Color(0xFF805306),
    iconMouseDown: Color(0xFFFFD500));

final windows.WindowButtonColors closeButtonColors = windows.WindowButtonColors(
    mouseOver: Colors.red[700],
    mouseDown: Colors.red[900],
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        windows.MinimizeWindowButton(colors: buttonColors),
        windows.MaximizeWindowButton(colors: buttonColors),
        windows.CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

class _DeviceMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final DeviceTypeRepository deviceTypeRepository =
        watch(deviceTypeRepositoryProvider);

    return Theme(
      // Hide tooltip.
      data: Theme.of(context).copyWith(
        tooltipTheme: const TooltipThemeData(
          decoration: BoxDecoration(color: Colors.transparent),
        ),
      ),
      child: PopupMenuButton<DeviceType>(
        itemBuilder: (BuildContext context) => <PopupMenuEntry<DeviceType>>[
          PopupMenuItem<DeviceType>(
            value: DeviceType.pc1500A,
            child: _CheckboxOption(
              label: 'Sharp PC-1500A',
              isSelected: deviceTypeRepository.deviceType == DeviceType.pc1500A,
            ),
          ),
          PopupMenuItem<DeviceType>(
              value: DeviceType.pc2,
              child: _CheckboxOption(
                label: 'Radio Shack PC-2',
                isSelected: deviceTypeRepository.deviceType == DeviceType.pc2,
              )),
        ],
        onSelected: (DeviceType deviceType) {
          deviceTypeRepository.deviceType = deviceType;
        },
        tooltip: '',
        enableFeedback: true,
        child: const Text('Device'),
      ),
    );
  }
}

class _CheckboxOption extends StatelessWidget {
  const _CheckboxOption({
    Key key,
    @required this.label,
    this.isSelected = false,
  })  : assert(label != null),
        super(key: key);

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 25.0,
          child: Text(isSelected ? '✓' : ''),
        ),
        Text(label)
      ],
    );
  }
}
