import 'package:flutter/material.dart';

import 'home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}
