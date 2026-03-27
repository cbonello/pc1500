import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc1500/src/pages/home/lcd.dart';
import 'package:pc1500/src/pages/home/skin.dart';
import 'package:pc1500/src/repositories/repositories.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          return Skin(
            skin: skin,
            lcd: lcd,
            device: deviceRepository.device,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
