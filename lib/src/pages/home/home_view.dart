import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/repositories.dart';
import 'lcd.dart';
import 'skin.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SystemsRepository> systemsRepository =
        ref.watch(systemsRepositoryProvider);
    final DeviceRepository deviceRepository =
        ref.watch(deviceRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFBABEC1),
      body: Center(
        child: systemsRepository.when<Widget>(
          data: (SystemsRepository repository) {
            final SkinModel skin = repository.getSkin(
              deviceRepository.type,
            );
            final LcdWidget lcd = LcdWidget(
              config: skin.lcd,
              eventsStream: deviceRepository.device.lcdEvents,
            );

            return Skin(
              skin: skin,
              lcd: lcd,
              device: deviceRepository.device,
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (Object err, StackTrace _) => Text('Error: $err'),
        ),
      ),
    );
  }
}
