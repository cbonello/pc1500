import 'package:flutter/material.dart';

import 'package:pc1500/src/pages/home/home_page.dart';

class PC1500App extends StatelessWidget {
  const PC1500App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sharp PC-1500',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, Widget Function(BuildContext)>{
        HomePage.routeName: (BuildContext _) => const HomePage(),
      },
      initialRoute: HomePage.routeName,
    );
  }
}
