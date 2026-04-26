import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BatchCard extends StatelessWidget {
  final String name;
  final String time;
  final String location;
  final num capacity;
  final num remaining;
  final VoidCallback? onTap;

  const BatchCard({
    super.key,
    required this.name,
    required this.time,
    required this.location,
    required this.capacity,
    required this.remaining,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = capacity == 0 ? 0.0 : remaining / capacity;
    final Color statusColor = remaining <= 0
        ? AppTheme.coral
        : ratio <= 0.25
            ? AppTheme.amber
            : AppTheme.aqua;

    final String statusLabel = remaining <= 0
        ? 'Full'
        : ratio <= 0.25
            ? 'Almost full'
            : 'Open';

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
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
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
            const SizedBox(height: 8),
            Text(location, style: const TextStyle(color: AppTheme.slate)),
            const SizedBox(height: 6),
            Text(time, style: const TextStyle(color: AppTheme.slate)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: capacity == 0 ? 0 : (remaining / capacity).clamp(0, 1).toDouble(),
              color: statusColor,
              backgroundColor: AppTheme.sky,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 10),
            Text(
              '${remaining.toString()} kg remaining of ${capacity.toString()} kg',
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
