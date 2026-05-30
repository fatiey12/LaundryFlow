import 'package:flutter/material.dart';
import 'package:laundryflow_app/models/announcement.dart';
import 'package:laundryflow_app/screens/history_screen.dart';
import 'package:laundryflow_app/screens/login_screen.dart';
import 'package:laundryflow_app/screens/notifications_screen.dart';
import 'package:laundryflow_app/services/announcement_store.dart';
import 'package:laundryflow_app/services/api_services.dart';
import 'package:laundryflow_app/services/socket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController weightController =
      TextEditingController();

  bool loading = false;

  List batches = [];

  double walletBalance = 0;

  double estimatedCost = 0;

  @override
  void initState() {
    super.initState();

    loadAll();
    setupSocket();

    weightController.addListener(() {
      calculateCost();
    });
  }

 
  // LOAD ALL
 
  void loadAll() async {
    await loadBatches();
    await loadWallet();
  }

  
  // LOAD BATCHES
  
  Future<void> loadBatches() async {
    final data =
        await ApiService.getBatches();

    setState(() {
      batches = data;
    });
  }

 
  // LOAD WALLET
  
  Future<void> loadWallet() async {
  try {
    final data =
        await ApiService.getWalletBalance();

    print("Wallet API Response:");
    print(data);

    double newBalance = 0;

    if (data["balance"] != null) {
      newBalance =
          double.parse(
            data["balance"].toString(),
          );
    } else if (data["walletBalance"] != null) {
      newBalance =
          double.parse(
            data["walletBalance"].toString(),
          );
    }

    setState(() {
      walletBalance = newBalance;
    });

  } catch (e) {
    print("Wallet Load Error: $e");
  }
}

  
  // COST CALCULATION
 
  void calculateCost() {
    if (weightController.text.isEmpty) {
      setState(() {
        estimatedCost = 0;
      });
      return;
    }

    final weight =
        double.tryParse(
              weightController.text,
            ) ??
            0;

    final washerCycles =
        (weight / 7).ceil();

    const dryerCycles = 1;

    final totalCycles =
        washerCycles + dryerCycles;

    setState(() {
      estimatedCost =
          totalCycles * 10;
    });
  }



// WEIGHT ESTIMATOR POPUP

void showEstimatorPopup() {
  String bagSize = "Medium";
  String contents = "Mostly Clothes";
  double fullness = 1.0;

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (
          context,
          setModalState,
        ) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            title: const Text(
              "Smart Weight Estimator",
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [

                  // BAG SIZE
                  const Text(
                    "Bag Size",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  DropdownButton<String>(
                    isExpanded: true,
                    value: bagSize,
                    items: const [

                      DropdownMenuItem(
                        value: "Small",
                        child:
                            Text("Small"),
                      ),

                      DropdownMenuItem(
                        value: "Medium",
                        child:
                            Text("Medium"),
                      ),

                      DropdownMenuItem(
                        value: "Large",
                        child:
                            Text("Large"),
                      ),
                    ],
                    onChanged: (v) {
                      setModalState(() {
                        bagSize = v!;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // CONTENTS
                  const Text(
                    "Main Contents",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  DropdownButton<String>(
                    isExpanded: true,
                    value: contents,
                    items: const [

                      DropdownMenuItem(
                        value:
                            "Mostly Clothes",
                        child: Text(
                          "Mostly Clothes",
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            "Clothes + Towels",
                        child: Text(
                          "Clothes + Towels",
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            "Heavy Items",
                        child: Text(
                          "Heavy Items / Bedding",
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setModalState(() {
                        contents = v!;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // FULLNESS
                  const Text(
                    "How Full Is It?",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Slider(
                    min: 0.25,
                    max: 1.0,
                    divisions: 3,
                    value: fullness,
                    label:
                        "${(fullness * 100).round()}%",
                    onChanged: (v) {
                      setModalState(() {
                        fullness = v;
                      });
                    },
                  ),

                  Center(
                    child: Text(
                      "${(fullness * 100).round()}% Full",
                    ),
                  ),
                ],
              ),
            ),

            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child:
                    const Text("Cancel"),
              ),

              ElevatedButton(
                onPressed: () {

                  double base = 7;

                  // BAG SIZE
                  if (bagSize ==
                      "Small") {
                    base = 4;
                  } else if (bagSize ==
                      "Medium") {
                    base = 7;
                  } else if (bagSize ==
                      "Large") {
                    base = 10;
                  }

                  // CONTENTS
                  if (contents ==
                      "Clothes + Towels") {
                    base += 2;
                  } else if (contents ==
                      "Heavy Items") {
                    base += 4;
                  }

                  final estimate =
                      (base *
                              fullness)
                          .round();

                  weightController.text =
                      estimate
                          .toString();

                  calculateCost();

                  Navigator.pop(
                    context,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Estimated Weight: $estimate kg added",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Use Estimate",
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
  
  // SOCKET
 
  void setupSocket() {
    SocketService.connect();

    SocketService.socket?.on(
      "announcement",
      (data) {
        AnnouncementStore.items.insert(
          0,
          Announcement(
            title: data["title"],
            message: data["message"],
            time: DateTime.now(),
          ),
        );

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              " Admin Update",
            ),
            content: Text(
              "${data["title"]}\n\n${data["message"]}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  "OK",
                ),
              )
            ],
          ),
        );
      },
    );
  }

  
  // TOP UP POPUP
 
  void showTopUpPopup() {
    final customController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "💳 Top Up Wallet",
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [

            topUpBtn(20),
            topUpBtn(50),
            topUpBtn(100),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  customController,
              keyboardType:
                  TextInputType
                      .number,
              decoration:
                  const InputDecoration(
                hintText:
                    "Custom amount",
              ),
            ),
          ],
        ),
        actions: [

          TextButton(
  onPressed: () async {

    if (customController.text.isNotEmpty) {

      await ApiService.topUpWallet(
        double.parse(
          customController.text,
        ),
      );
    }

    Navigator.pop(context);

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    await loadWallet();

    setState(() {});
  },
  child: const Text("Add Funds"),
)
        ],
      ),
    );
  }
// fix this part for the wallet change thingy

 Widget topUpBtn(double amount) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {

          await ApiService.topUpWallet(amount);

          Navigator.pop(context);

          await Future.delayed(
            const Duration(milliseconds: 300),
          );

          await loadWallet();

          setState(() {});
        },
        child: Text("+ $amount DH"),
      ),
    ),
  );
}

  
  // BOOKING
  
  void createBooking(
    String batchId,
  ) async {
    if (weightController.text
        .isEmpty) {
      snack(
        "Enter weight first",
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result =
          await ApiService
              .createBooking(
        double.parse(
          weightController.text,
        ),
        batchId,
      );

      loadAll();

      setState(() {
        loading = false;
      });

      String prediction =
          "Unknown";

      final p =
          result["prediction"]
              .toString();

      if (p.contains(
        "LOW",
      )) {
        prediction =
            "🟢 Low Traffic";
      } else if (p.contains(
        "MEDIUM",
      )) {
        prediction =
            "🟡 Moderate Queue";
      } else if (p.contains(
        "HIGH",
      )) {
        prediction =
            "🔴 High Demand";
      }

      final pricing =
          result["pricing"];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
          title: const Text(
            "✅ Booking Confirmed",
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [

              Text(
                "Batch $batchId Reserved",
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                "Charged: ${pricing["totalCost"]} DH",
              ),

              Text(
                "Balance Left: ${walletBalance.toStringAsFixed(0)} DH",
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                "🏢 Building: ${result["building"]}",
              ),

              Text(
                "Ready By: ${result["estimatedReadyTime"]}",
              ),

              Text(
                "Queue: $prediction",
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                "💡 ${result["message"]}",
                style:
                    const TextStyle(
                  color:
                      Colors.green,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text(
                "Great",
              ),
            )
          ],
        ),
      );
    } catch (e) {
      setState(() {
        loading = false;
      });

      snack(
        e.toString(),
      );
    }
  }

  
  // SNACKBAR
 
  void snack(
    String text,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          text,
        ),
      ),
    );
  }

  
  // UI
  
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF4F7F5,
      ),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(
          0xFF1F8F63,
        ),
        title: const Text(
          "LaundryFlow",
        ),
        actions: [

          IconButton(
            icon: const Icon(
              Icons.history,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const HistoryScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.notifications,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationsScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              await ApiService
                  .logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LoginScreen(),
                ),
                (
                  route,
                ) =>
                    false,
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          loadAll();
        },
        child: ListView(
          padding:
              const EdgeInsets.all(
            16,
          ),
          children: [

            // HEADER
            Container(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(
                      0xFF2ECC71,
                    ),
                    Color(
                      0xFF1F8F63,
                    ),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [

                  Text(
                    "Good Afternoon",
                    style:
                        TextStyle(
                      color: Colors
                          .white70,
                    ),
                  ),

                  SizedBox(
                    height: 6,
                  ),

                  Text(
                    "Student Laundry Portal",
                    style:
                        TextStyle(
                      fontSize:
                          22,
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // WALLET CARD
            GestureDetector(
              onTap:
                  showTopUpPopup,
              child: Card(
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    18,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          const Text(
                            "Wallet Balance",
                            style:
                                TextStyle(
                              color: Colors
                                  .grey,
                            ),
                          ),

                          const SizedBox(
                            height:
                                6,
                          ),

                          Text(
                            "${walletBalance.toStringAsFixed(0)} DH",
                            style:
                                const TextStyle(
                              fontSize:
                                  26,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Colors.green,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              14,
                          vertical:
                              10,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .green,
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child:
                            const Text(
                          "+ Top Up",
                          style:
                              TextStyle(
                            color: Colors
                                .white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // BOOKING CARD
            Card(
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    const Text(
                      "Enter Laundry Weight",
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize:
                            16,
                      ),
                    ),

                    const SizedBox(
                      height:
                          12,
                    ),

                    TextField(
                      controller:
                          weightController,
                      keyboardType:
                          TextInputType
                              .number,
                      decoration:
                          InputDecoration(
                        hintText:
                            "e.g 13",
                        suffixText:
                            "kg",
                        filled:
                            true,
                        fillColor:
                            Colors.grey[
                                100],
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
// Estimating thingy for weight

const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    icon: const Icon(
      Icons.auto_awesome,
      color: Colors.green,
    ),
    label: const Text(
      "Estimate My Laundry Weight",
      style: TextStyle(
        color: Colors.green,
        fontWeight:
            FontWeight.bold,
      ),
    ),
    style:
        OutlinedButton.styleFrom(
      side: const BorderSide(
        color: Colors.green,
      ),
      padding:
          const EdgeInsets.symmetric(
        vertical: 14,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
    ),
    onPressed:
        showEstimatorPopup,
  ),
),
                    const SizedBox(
                      height:
                          12,
                    ),

                    Text(
                      "Estimated Cost: ${estimatedCost.toStringAsFixed(0)} DH",
                      style:
                          const TextStyle(
                        color: Colors
                            .green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height:
                          4,
                    ),

                    const Text(
                      "Includes washer cycles + 1 dryer cycle",
                      style:
                          TextStyle(
                        color: Colors
                            .grey,
                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              "Available Batches",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // BATCHES
            ...batches.map(
              (
                batch,
              ) =>
                  Card(
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.all(
                    14,
                  ),

                  title: Text(
                    "Batch ${batch["id"]}",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle:
                      Text(
                    "${batch["start"]}:00 - ${batch["end"]}:00\n${batch["booked"]}/${batch["capacity"]} booked",
                  ),

                  trailing:
                      batch["isFull"]
                          ? Container(
                              padding:
                                  const EdgeInsets.all(
                                8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.red[100],
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child:
                                  const Text(
                                "FULL",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.red,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF1F8F63,
                                ),
                              ),
                              onPressed:
                                  loading
                                      ? null
                                      : () {
                                          createBooking(
                                            batch["id"],
                                          );
                                        },
                              child:
                                  loading
                                      ? const SizedBox(
                                          width:
                                              18,
                                          height:
                                              18,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,
                                            color:
                                                Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Book",
                                        ),
                            ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Card(
              color:
                  Colors.green[50],
              child:
                  const Padding(
                padding:
                    EdgeInsets.all(
                  16,
                ),
                child: Text(
                  "Need help? Visit the laundry desk for support.",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Object? {
  int? operator [](String other) {}
}