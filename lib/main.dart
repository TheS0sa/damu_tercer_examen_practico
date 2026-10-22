import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/app_controller.dart';

void main() {
  runApp(const SimpsonsExplorerApp());
}

class SimpsonsExplorerApp extends StatefulWidget {
  const SimpsonsExplorerApp({super.key});

  @override
  State<SimpsonsExplorerApp> createState() => _SimpsonsExplorerAppState();
}

class _SimpsonsExplorerAppState extends State<SimpsonsExplorerApp> {
  late final SimpsonsAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpsonsAppController();
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF25243A);
    const paper = Color(0xFFFFF8E9);

    return MaterialApp(
      title: 'Springfield Archive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE7653B),
          primary: const Color(0xFFE7653B),
          secondary: const Color(0xFF4B8F83),
          surface: paper,
          onSurface: ink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: paper,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE9E0D0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE9E0D0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE7653B), width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFE9E0D0)),
          ),
        ),
      ),
      home: CatalogHomeScreen(controller: _controller),
    );
  }
}
