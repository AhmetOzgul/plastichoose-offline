import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plastichoose/app/di.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';
import 'package:plastichoose/features/decision/presentation/controllers/review_deck_controller.dart';
import 'package:plastichoose/features/decision/presentation/widgets/modern_review_card.dart';
import 'package:plastichoose/core/widgets/gradient_button.dart';

final class ReviewDeckPage extends StatelessWidget {
  const ReviewDeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReviewDeckController>(
      create: (_) => ReviewDeckController(
        listPatients: getIt<ListPatients>(),
        decidePatient: getIt<DecidePatient>(),
      )..refresh(),
      child: const _ReviewDeckPageContent(),
    );
  }
}

final class _ReviewDeckPageContent extends StatelessWidget {
  const _ReviewDeckPageContent();

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.white,
              secondary.withOpacity(0.05),
              tertiary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hasta İnceleme',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                    ),
                    const Spacer(),
                    Consumer<ReviewDeckController>(
                      builder:
                          (
                            BuildContext context,
                            ReviewDeckController controller,
                            Widget? child,
                          ) {
                            return Text(
                              '${controller.newPatients.length} hasta',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            );
                          },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<ReviewDeckController>(
                  builder:
                      (
                        BuildContext context,
                        ReviewDeckController controller,
                        Widget? child,
                      ) {
                        if (controller.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (controller.errorMessage != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Hasta listesi yüklenirken hata oluştu',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.red.shade600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.errorMessage!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  child: SizedBox(
                                    width: 150,
                                    child: GradientButton(
                                      colors: <Color>[secondary, tertiary],
                                      onPressed: controller.refresh,
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Tekrar Dene',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (controller.newPatients.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Colors.green.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tüm hastalar incelendi!',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.green.shade600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Yeni hasta kayıtları geldiğinde burada görünecek',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  child: SizedBox(
                                    width: 150,
                                    child: GradientButton(
                                      colors: <Color>[secondary, tertiary],
                                      onPressed: controller.refresh,
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Yenile',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ModernReviewCard(
                          patient: controller.currentPatient!,
                          onDecision: (p, status) {
                            if (status == DecisionStatus.accepted) {
                              controller.acceptPatient(p);
                            } else if (status == DecisionStatus.rejected) {
                              controller.rejectPatient(p);
                            }
                          },
                          onSkip: (p) => controller.skipPatient(p),
                          secondary: secondary,
                          tertiary: tertiary,
                        );
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
