import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plastichoose/app/router.dart';
import 'package:plastichoose/app/themes/theme.dart';

/// Root app widget configuring router and theme.
final class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = buildRouter();
    return MaterialApp.router(
      routerConfig: router,
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
