import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plastichoose/features/common/widgets/custom_app_bar.dart';

/// Home page with grid navigation to feature sections.
final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_HomeItem> items = <_HomeItem>[
      const _HomeItem(
        icon: Icons.rate_review,
        label: 'İnceleme',
        route: '/decide',
        subtitle: 'Hasta değerlendirme',
        color: null,
      ),
      const _HomeItem(
        icon: Icons.people,
        label: 'Hastalar',
        route: '/patients',
        subtitle: 'Hasta listesi',
        color: null,
      ),
      const _HomeItem(
        icon: Icons.add_circle_outline,
        label: 'Yeni Hasta',
        route: '/add',
        subtitle: 'Hasta oluştur',
        color: Colors.blue,
      ),
      const _HomeItem(
        icon: Icons.cleaning_services,
        label: 'Temizlik',
        route: '/cleanup',
        subtitle: 'Eski kayıtları sil',
        color: Colors.red,
      ),
      const _HomeItem(
        icon: Icons.ios_share,
        label: 'Çıktı Alma',
        route: '/export',
        subtitle: 'Veri dışa aktar',
        color: Colors.blue,
      ),
    ];
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color secondary = scheme.secondary;
    final Color tertiary = scheme.tertiary;
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
          top: false,
          child: Column(
            children: <Widget>[
              CustomAppBar(
                secondary: secondary,
                tertiary: tertiary,
                title: 'PlastiChoose',
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: items
                        .map(
                          (e) => _QuickAccessCard(
                            icon: e.icon,
                            title: e.label,
                            subtitle: e.subtitle ?? '',
                            color: e.color ?? scheme.secondary,
                            onTap: () => context.go(e.route),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _HomeItem {
  final IconData icon;
  final String label;
  final String route;
  final String? subtitle;
  final Color? color;
  const _HomeItem({
    required this.icon,
    required this.label,
    required this.route,
    this.subtitle,
    this.color,
  });
}
