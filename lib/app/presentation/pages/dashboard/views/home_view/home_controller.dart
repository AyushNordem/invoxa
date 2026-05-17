import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/app_constants.dart';
import '../../../../../data/models/invoice_model.dart';

class HomeController extends GetxController {
  final userName = 'User'.obs;
  final isLoading = true.obs;

  // Realtime Data
  final allInvoices = <InvoiceModel>[].obs;
  final recentInvoices = <InvoiceModel>[].obs;

  // Aggregate Stats
  final paidAmount = 0.0.obs;
  final pendingAmount = 0.0.obs;
  final totalRevenue = 0.0.obs;
  final invoiceCount = 0.obs;
  final activeCustomersCount = 0.obs;
  final billingGrowth = 0.0.obs;

  // Dynamic Chart Data
  final chartSpots = <FlSpot>[].obs;
  final chartMonths = <String>[].obs;

  StreamSubscription? _invoiceSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    _startInvoiceListener();
  }

  @override
  void onClose() {
    _invoiceSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(user.uid).get();

        if (doc.exists) {
          userName.value = doc.data()?['fullName'] ?? 'User';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _startInvoiceListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _invoiceSubscription = FirebaseFirestore.instance
        .collection('invoices')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.data(), id: doc.id)).toList();

      // In-memory sort: latest first
      list.sort((a, b) {
        final dateA = a.createdAt ?? a.date ?? DateTime.now();
        final dateB = b.createdAt ?? b.date ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      allInvoices.value = list;

      // Aggregation Calculations
      double paid = 0.0;
      double pending = 0.0;
      final customers = <String>{};

      for (var invoice in list) {
        final status = (invoice.status ?? '').toUpperCase();
        if (status == 'PAID') {
          paid += invoice.grandTotal;
        } else if (status == 'PENDING' || status == 'OVERDUE') {
          pending += invoice.grandTotal;
        }
        if (invoice.buyerDetails?.name != null) {
          customers.add(invoice.buyerDetails!.name!);
        }
      }

      paidAmount.value = paid;
      pendingAmount.value = pending;
      totalRevenue.value = paid;
      invoiceCount.value = list.length;
      activeCustomersCount.value = customers.length;

      // Calculate Past 6 Months dynamic spots
      _calculateMonthlyBilling(list);

      // Take top 4 for recent activities
      recentInvoices.value = list.take(4).toList();

      isLoading.value = false;
    }, onError: (e) {
      print('Error listening to invoices: $e');
      isLoading.value = false;
    });
  }

  void _calculateMonthlyBilling(List<InvoiceModel> invoices) {
    final now = DateTime.now();
    final months = <DateTime>[];

    // 1. Get the last 6 months (including the current month)
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }

    // 2. Map dynamic month abbreviations (e.g. "DEC", "JAN", "FEB", "MAR", "APR", "MAY")
    final labels = months.map((m) => DateFormat('MMM').format(m).toUpperCase()).toList();
    chartMonths.value = labels;

    // 3. Sum grandTotal for each month
    final spots = <FlSpot>[];
    for (int i = 0; i < 6; i++) {
      final targetMonth = months[i];
      double monthlySum = 0.0;

      for (var inv in invoices) {
        final invDate = inv.date ?? inv.createdAt;
        if (invDate != null && invDate.year == targetMonth.year && invDate.month == targetMonth.month) {
          monthlySum += inv.grandTotal;
        }
      }

      spots.add(FlSpot(i.toDouble(), monthlySum));
    }

    chartSpots.value = spots;

    // 4. Billing Growth Percentage: Compare current month (index 5) with previous month (index 4)
    final currentMonthTotal = spots[5].y;
    final lastMonthTotal = spots[4].y;

    if (lastMonthTotal > 0) {
      final growth = ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
      billingGrowth.value = growth;
    } else if (currentMonthTotal > 0) {
      billingGrowth.value = 100.0;
    } else {
      billingGrowth.value = 0.0;
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
