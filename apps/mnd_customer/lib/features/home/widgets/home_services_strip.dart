import 'package:flutter/material.dart';

import '../../../widgets/app_snackbar.dart';
import '../../food/food_page.dart';
import '../models/home_catalog_models.dart';

/// Top-of-home row: Rides, Food, Market, Delivery (all visible, no horizontal scroll).
class HomeServicesStrip extends StatelessWidget {
  const HomeServicesStrip({super.key, required this.services});

  final List<HomeService> services;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < services.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _ServiceTile(service: services[i])),
          ],
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final HomeService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (service.id == HomeServiceId.food) {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const FoodPage()),
            );
            return;
          }
          AppSnackBar.showInfo(
            context,
            message: '${service.label} is coming soon.',
            icon: Icons.hourglass_top_rounded,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(service.icon, size: 28, color: cs.primary),
              const SizedBox(height: 8),
              Text(
                service.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
