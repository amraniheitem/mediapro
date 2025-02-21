// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mediapro/Bottom/bottombar.dart';
import 'package:mediapro/Login/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Media Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
    );
  }
}
