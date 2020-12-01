import 'package:flutter/material.dart';

import 'pages/home/home_page.dart';

class PC1500App extends StatelessWidget {
  const PC1500App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
