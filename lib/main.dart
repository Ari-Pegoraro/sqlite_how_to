import 'package:f290_flutter_sqlite_how_to/screens/main_screen.dart';
import 'package:flutter/material.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          theme: ThemeData.dark(),
          home: MainScreen(),
        );
  }
}
