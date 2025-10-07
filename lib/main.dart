import 'package:flutter/material.dart';
import 'package:plastichoose/app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastichoose/app/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  configureDependencies();
  runApp(const MyApp());
}
