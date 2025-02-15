import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart'; // Assuming your app logic is in app.dart
import 'theme_provider.dart'; // Assuming you have a separate file for ThemeProvider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const RepeatedTextApp(),
    ),
  );
}
