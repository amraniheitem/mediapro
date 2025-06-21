import 'package:flutter/material.dart';
import 'package:mediapro/Bottom/bottombar.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important !
  await initializeDateFormatting('fr_FR', null); // Initialisation locale

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Media Pro',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BottomNavbar(),
    );
  }
}
