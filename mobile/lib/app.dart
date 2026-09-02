import 'package:flutter/material.dart';

import 'features/screens/home_page.dart';

class GibelaSAApp extends StatelessWidget {
  const GibelaSAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GibelaSA',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
      ),

      home: const HomePage(),
    );
  }
}
