import 'package:flutter/material.dart';
import 'package:gibela_sa/features/widgets/router.dart';

class GibelaSAApp extends StatelessWidget {
  const GibelaSAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GibelaSA',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 0, 0),
        ),
      ),
    );
  }
}
