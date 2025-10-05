import 'package:get_it/get_it.dart';
import 'package:plastichoose/features/patients/data/repositories/patients_repository_impl.dart';
import 'package:plastichoose/features/patients/domain/repositories/patients_repository.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Registers application dependencies.
void configureDependencies() {
  // Repository
  getIt.registerLazySingleton<PatientsRepository>(
    () => PatientsRepositoryImpl(),
  );

  // Use cases
  getIt.registerFactory<AddPatient>(
    () => AddPatient(getIt<PatientsRepository>()),
  );

  getIt.registerFactory<DeletePatient>(
    () => DeletePatient(getIt<PatientsRepository>()),
  );

  getIt.registerFactory<UpdatePatient>(
    () => UpdatePatient(getIt<PatientsRepository>()),
  );

  getIt.registerFactory<ListPatients>(
    () => ListPatients(getIt<PatientsRepository>()),
  );

  getIt.registerFactory<GetPatient>(
    () => GetPatient(getIt<PatientsRepository>()),
  );

  getIt.registerFactory<DecidePatient>(
    () => DecidePatient(getIt<PatientsRepository>()),
  );

  getIt.registerFactory<UndoDecision>(
    () => UndoDecision(getIt<PatientsRepository>()),
  );
}
