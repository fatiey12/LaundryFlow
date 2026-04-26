import 'package:flutter/material.dart';
import '../services/api_services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  void fetchBookings() async {
    try {
      final data = await ApiService.getMyBookings();

      setState(() {
        bookings = data;
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: Colors.green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text("No bookings yet"))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text("Weight: ${b['weight']} kg"),
                        subtitle: Text(
                          "Status: ${b['status']}\nDate: ${b['createdAt']}",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}