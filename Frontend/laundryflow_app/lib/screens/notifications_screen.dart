import 'package:flutter/material.dart';
import '../services/announcement_store.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = AnnouncementStore.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text("No notifications yet"),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final n = items[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.notifications,
                      color: Colors.green,
                    ),
                    title: Text(n.title),
                    subtitle: Text(
                      "${n.message}\n\n${n.time.hour}:${n.time.minute.toString().padLeft(2, '0')}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}