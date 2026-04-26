import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final Future<void> Function() onLogout;

  const ProfileScreen({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoggingOut = false;
  int bookingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await ApiService.getMyBookings();
      if (!mounted) {
        return;
      }
      setState(() {
        bookingCount = bookings.length;
      });
    } catch (_) {}
  }

  Future<void> _logout() async {
    setState(() {
      isLoggingOut = true;
    });

    await widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name']?.toString() ?? 'AUI Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user['email']?.toString() ?? '',
                    style: const TextStyle(color: Color(0xFFD9E7F7)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Student ID: ${user['student_id'] ?? 'Not set'}',
                    style: const TextStyle(color: Color(0xFFD9E7F7)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Residence: ${user['residence'] ?? 'Not provided'}',
                    style: const TextStyle(color: Color(0xFFD9E7F7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Bookings made',
                    value: '$bookingCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Account type',
                    value: 'Student',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoggingOut ? null : _logout,
                child: Text(isLoggingOut ? 'Signing out...' : 'Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppTheme.slate)),
        ],
      ),
    );
  }
}
