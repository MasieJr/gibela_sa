import 'package:flutter/material.dart';

import 'core/di/injection.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const GibelaSAApp());
}
