import 'package:flutter/material.dart';

import 'routing/app_router.dart';

void main() {
  runApp(const AbalyApp());
}

class AbalyApp extends StatelessWidget {
  const AbalyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Abaly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
