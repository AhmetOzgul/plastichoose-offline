import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plastichoose/features/patients/presentation/pages/add_patient_page.dart';
import 'package:plastichoose/features/home/presentation/pages/_stubs.dart';
import 'package:plastichoose/features/home/presentation/pages/home_page.dart';
import 'package:plastichoose/features/decision/presentation/pages/review_deck_page.dart';
import 'package:plastichoose/features/patients/presentation/pages/patient_list_page.dart';

/// Builds the application router.
GoRouter buildRouter() {
  final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomePage(),
        routes: <RouteBase>[
          GoRoute(
            path: 'add',
            builder: (BuildContext context, GoRouterState state) =>
                const AddPatientPage(),
          ),
          GoRoute(
            path: 'patients',
            builder: (BuildContext context, GoRouterState state) =>
                const PatientListPage(),
          ),
          GoRoute(
            path: 'decide',
            builder: (BuildContext context, GoRouterState state) =>
                const ReviewDeckPage(),
          ),
          GoRoute(
            path: 'export',
            builder: (BuildContext context, GoRouterState state) =>
                const ExportPage(),
          ),
          GoRoute(
            path: 'cleanup',
            builder: (BuildContext context, GoRouterState state) =>
                const CleanupPage(),
          ),
        ],
      ),
    ],
  );
}
