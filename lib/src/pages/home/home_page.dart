import 'package:flutter/material.dart';

import 'package:pc1500/src/pages/home/home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}
