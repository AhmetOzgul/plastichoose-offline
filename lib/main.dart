import 'package:flutter/material.dart';
import 'package:plastichoose/app/app.dart';
import 'package:plastichoose/app/di.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}
