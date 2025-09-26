/// Result and Failure primitives for error-aware flows.
sealed class Result<T> {
  const Result();
  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure f) err,
  });
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
  @override
  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure f) err,
  }) => ok(value);
}

final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
  @override
  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure f) err,
  }) => err(failure);
}

sealed class Failure {
  final String message;
  final Object? cause;
  const Failure(this.message, [this.cause]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(String message, [Object? cause]) : super(message, cause);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
