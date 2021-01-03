import 'package:bitsdojo_window/bitsdojo_window.dart' as windows;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../repositories/repositories.dart';
import 'lcd.dart';
import 'skin.dart';

const Color borderColor = Color(0xFF805306);

class HomeView extends ConsumerWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final AsyncValue<SystemsRepository> systemsRepository =
        watch(systemsRepositoryProvider);
    // final DeviceTypeRepository deviceTypeRepository =
    //     watch(deviceTypeRepositoryProvider);
    // final DebugPortRepository debugPortRepository =
    //     watch(debugPortRepositoryProvider);
    final DeviceRepository deviceRepository = watch(deviceRepositoryProvider);

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
                  // final Device device = Device(
                  //   type: deviceTypeRepository.deviceType,
                  //   debugPort: debugPortRepository.debugPort,
                  // )..init();
                  final SkinModel skin = repository.getSkin(
                    // deviceTypeRepository.deviceType,
                    deviceRepository.type,
                  );
                  final LcdWidget lcd = LcdWidget(
                    config: skin.lcd,
                    eventsStream: deviceRepository.device.lcdEvents,
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
    final DeviceRepository deviceRepository = watch(deviceRepositoryProvider);

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
            value: DeviceType.pc1500,
            child: _CheckboxOption(
              label: 'Sharp PC-1500',
              isSelected: deviceRepository.type == DeviceType.pc1500,
            ),
          ),
          PopupMenuItem<DeviceType>(
              value: DeviceType.pc2,
              child: _CheckboxOption(
                label: 'Radio Shack PC-2',
                isSelected: deviceRepository.type == DeviceType.pc2,
              )),
          PopupMenuItem<DeviceType>(
            value: DeviceType.pc1500A,
            child: _CheckboxOption(
              label: 'Sharp PC-1500A',
              isSelected: deviceRepository.type == DeviceType.pc1500A,
            ),
          ),
        ],
        onSelected: (DeviceType deviceType) async {
          bool canSwitch = deviceRepository.canSafelySwitchDevices(deviceType);
          if (canSwitch == false) {
            canSwitch = await _acknowledgeDeviceSwitch(context);
          }
          if (canSwitch) {
            deviceRepository.type = deviceType;
          }
        },
        tooltip: '',
        enableFeedback: true,
        child: const Text('Device'),
      ),
    );
  }

  Future<bool> _acknowledgeDeviceSwitch(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            '''
Switching to a new device may cause any un-saved code/data to be lost.
Debug clients will also be disconnected. Do you want to continue?
''',
            softWrap: true,
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.black,
              padding: const EdgeInsets.all(20.0),
              autofocus: true,
              onPressed: () => Navigator.of(context).pop<bool>(true),
              child: const Text('Continue'),
            ),
            FlatButton(
              textColor: Colors.black,
              padding: const EdgeInsets.all(20.0),
              onPressed: () => Navigator.of(context).pop<bool>(false),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
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
