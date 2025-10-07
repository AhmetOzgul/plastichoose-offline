import 'package:flutter/material.dart';

/// Utilities for working with DateTime and DateTimeRange in a consistent way.
final class DateRangeUtils {
  const DateRangeUtils._();

  /// Returns a new [DateTimeRange] where the start is at the start of the day
  /// (00:00:00.000) and the end is at the end of the day (23:59:59.999).
  static DateTimeRange? normalizeInclusive(DateTimeRange? range) {
    if (range == null) return null;
    final DateTime start = startOfDay(range.start);
    final DateTime end = endOfDay(range.end);
    return DateTimeRange(start: start, end: end);
  }

  /// Returns the start of the day for [dt].
  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Returns the end of the day for [dt] (23:59:59.999).
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);
}
