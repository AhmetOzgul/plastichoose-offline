import 'package:plastichoose/core/result/result.dart';

/// Base use case interface.
abstract interface class UseCase<T, P> {
  Future<Result<T>> execute(P params);
}
