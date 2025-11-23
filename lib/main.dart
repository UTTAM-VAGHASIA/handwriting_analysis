import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(HandwritingAnalysisApp());
}

class HandwritingAnalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Handwriting Analysis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
