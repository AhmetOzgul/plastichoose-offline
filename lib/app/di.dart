import 'package:get_it/get_it.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Registers application dependencies.
void configureDependencies() {
  // Core clients/services would be registered here.
  // Example:
  // getIt.registerSingleton<Dio>(Dio());

  // Data sources, repositories, and use cases will be registered
  // incrementally as features are implemented.
}
