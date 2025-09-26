import 'package:flutter/material.dart';

final class AddPatientPage extends StatelessWidget {
  const AddPatientPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Hasta Ekle')));
}

final class PatientsListPage extends StatelessWidget {
  const PatientsListPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Hastalar Listesi')));
}

final class DecidePage extends StatelessWidget {
  const DecidePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Karar Ver')));
}

final class ExportPage extends StatelessWidget {
  const ExportPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Çıktı Alma')));
}

final class CleanupPage extends StatelessWidget {
  const CleanupPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Temizleme')));
}
