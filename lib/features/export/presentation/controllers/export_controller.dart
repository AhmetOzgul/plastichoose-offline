import 'package:flutter/material.dart';
import 'package:plastichoose/core/result/result.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:excel/excel.dart' as xls;
import 'package:external_path/external_path.dart';

/// Controls export operations: filtering and previewing export payload.
final class ExportController extends ChangeNotifier {
  final ListPatients _listPatients;

  ExportController({required ListPatients listPatients})
    : _listPatients = listPatients;

  ExportFormat selectedFormat = ExportFormat.excel;
  DateTimeRange? _range;
  bool includeUndecided = true;
  bool includeAccepted = true;
  bool includeRejected = false;

  bool isLoading = false;
  String? errorMessage;

  int patientsCount = 0;

  List<Patient> _lastPreviewPatients = <Patient>[];

  void setRange(DateTimeRange? range) {
    _range = range;
    notifyListeners();
  }

  String getDateRangeText() {
    if (_range == null) return 'Tümü';
    final DateTime start = _range!.start;
    final DateTime end = _range!.end;
    return '${start.day}.${start.month}.${start.year} - ${end.day}.${end.month}.${end.year}';
  }

  Future<void> toggleOption({
    bool? undecided,
    bool? accepted,
    bool? rejected,
  }) async {
    if (undecided != null) includeUndecided = undecided;
    if (accepted != null) includeAccepted = accepted;
    if (rejected != null) includeRejected = rejected;
    await refreshPreview();
  }

  void setFormat(ExportFormat format) {
    selectedFormat = format;
    notifyListeners();
  }

  Future<void> refreshPreview() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _lastPreviewPatients = await _collectPatients();
      patientsCount = _lastPreviewPatients.length;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Önizleme hesaplanamadı';
      notifyListeners();
    }
  }

  Future<List<Patient>> _collectPatients() async {
    final List<DecisionStatus> statuses = <DecisionStatus>[
      if (includeUndecided) DecisionStatus.none,
      if (includeAccepted) DecisionStatus.accepted,
      if (includeRejected) DecisionStatus.rejected,
    ];
    final List<Patient> aggregated = <Patient>[];
    for (final DecisionStatus s in statuses) {
      final Result<List<Patient>> res = await _listPatients.execute(
        ListPatientsParams(status: s),
      );
      res.when(
        ok: (List<Patient> list) => aggregated.addAll(list),
        err: (_) {},
      );
    }
    return aggregated
        .where((Patient p) {
          if (_range == null) return true;
          final DateTime d = p.createdAt;
          return !d.isBefore(_range!.start) && !d.isAfter(_range!.end);
        })
        .toList(growable: false);
  }

  List<Patient> getPreviewPatients() =>
      List<Patient>.unmodifiable(_lastPreviewPatients);

  /// Generates a file in the requested format and returns the saved file path.
  Future<String> generateAndSave({required ExportFormat format}) async {
    final List<Patient> patients = _lastPreviewPatients;
    final DateTime now = DateTime.now();
    final String timestamp =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}-'
        '${now.minute.toString().padLeft(2, '0')}-'
        '${now.second.toString().padLeft(2, '0')}';
    final String formatLabel = _formatSuffix(format);
    final String baseName = 'hasta_listesi_${timestamp}_${formatLabel}';

    final Directory targetDir = await _resolveTargetDirectory();

    switch (format) {
      case ExportFormat.txt:
        final String path = '${targetDir.path}/$baseName.txt';
        final String content = _buildTxt(patients);
        final File file = File(path);
        await file.writeAsString(content);
        return path;
      case ExportFormat.excel:
        final String path = '${targetDir.path}/$baseName.xlsx';
        final List<int> bytes = _buildExcelBytes(patients);
        final File file = File(path);
        await file.writeAsBytes(bytes, flush: true);
        return path;
      case ExportFormat.word:
        final String path = '${targetDir.path}/$baseName.doc';
        final String content = _buildTxt(patients); // simple doc text stub
        final File file = File(path);
        await file.writeAsString(content);
        return path;
    }
  }

  Future<Directory> _resolveTargetDirectory() async {
    if (Platform.isAndroid) {
      final String? downloadsPath = await _androidPublicDownloads();
      if (downloadsPath != null) return Directory(downloadsPath);
    }
    return getApplicationDocumentsDirectory();
  }

  Future<String?> _androidPublicDownloads() async {
    try {
      final String dir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );
      return dir;
    } catch (_) {
      return null;
    }
  }

  Future<void> shareFile(String path) async {
    await Share.shareXFiles(<XFile>[XFile(path)]);
  }

  String _buildTxt(List<Patient> patients) {
    final StringBuffer sb = StringBuffer();
    for (final Patient p in patients) {
      sb.writeln('${p.name} - ${_decisionLabel(p.decisionStatus)}');
    }
    return sb.toString();
  }

  List<int> _buildExcelBytes(List<Patient> patients) {
    final xls.Excel excel = xls.Excel.createExcel();
    final xls.Sheet sheet = excel['Sheet1'];
    sheet.appendRow(<xls.CellValue?>[
      xls.TextCellValue('İsim'),
      xls.TextCellValue('Karar'),
    ]);
    for (final Patient p in patients) {
      sheet.appendRow(<xls.CellValue?>[
        xls.TextCellValue(p.name),
        xls.TextCellValue(_decisionLabel(p.decisionStatus)),
      ]);
    }
    // Remove all other default sheets except the one we filled
    excel.sheets.keys
        .where((String name) => name != 'Sheet1')
        .toList()
        .forEach(excel.delete);
    return excel.encode()!;
  }

  String _decisionLabel(DecisionStatus status) {
    switch (status) {
      case DecisionStatus.accepted:
        return 'Kabul';
      case DecisionStatus.rejected:
        return 'Red';
      case DecisionStatus.none:
        return 'Beklemede';
    }
  }

  String _formatSuffix(ExportFormat f) {
    switch (f) {
      case ExportFormat.excel:
        return 'excel';
      case ExportFormat.txt:
        return 'txt';
      case ExportFormat.word:
        return 'word';
    }
  }
}

enum ExportFormat { excel, txt, word }
