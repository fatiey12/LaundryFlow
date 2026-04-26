import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LaundryCard extends StatelessWidget {
  final String name;
  final String code;
  final String zone;
  final int availableMachines;
  final int totalMachines;
  final String? nextAvailableSlot;
  final VoidCallback onTap;

  const LaundryCard({
    super.key,
    required this.name,
    required this.code,
    required this.zone,
    required this.availableMachines,
    required this.totalMachines,
    required this.nextAvailableSlot,
    required this.onTap,
  });

  Color get statusColor {
    if (availableMachines <= 0) {
      return AppTheme.coral;
    }

    final ratio = totalMachines == 0 ? 0.0 : availableMachines / totalMachines;
    if (ratio <= 0.25) {
      return AppTheme.amber;
    }
    return AppTheme.aqua;
  }

  String get statusLabel {
    if (availableMachines <= 0) {
      return 'Full';
    }

    final ratio = totalMachines == 0 ? 0.0 : availableMachines / totalMachines;
    if (ratio <= 0.25) {
      return 'Busy';
    }
    return 'Available';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$code • $zone',
                        style: const TextStyle(color: AppTheme.slate),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    label: 'Machines free',
                    value: '$availableMachines / $totalMachines',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoChip(
                    label: 'Next slot',
                    value: nextAvailableSlot ?? 'No upcoming slot',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.slate)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
