import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/models/invoice_model.dart';

class InvoiceController extends GetxController {
  final isLoading = false.obs;

  // Real-time synchronization lists
  final allInvoices = <InvoiceModel>[].obs;
  final filteredInvoices = <InvoiceModel>[].obs;

  // Search
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Analytics values
  final totalReceivable = 0.0.obs;
  final paidAmount = 0.0.obs;
  final pendingAmount = 0.0.obs;
  final invoiceCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();

    // Listen to search query changes to filter invoices
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterInvoices();
    });
  }

  void fetchInvoices() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isLoading.value = true;

    // Real-time snapshots listener
    FirebaseFirestore.instance
        .collection('invoices')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        return InvoiceModel.fromMap(doc.data(), id: doc.id);
      }).toList();

      // Sort in memory by createdAt descending
      list.sort((a, b) {
        final aDate = a.createdAt ?? a.date ?? DateTime.now();
        final bDate = b.createdAt ?? b.date ?? DateTime.now();
        return bDate.compareTo(aDate);
      });

      allInvoices.value = list;
      filterInvoices();
      calculateAnalytics();
      isLoading.value = false;
    }, onError: (error) {
      print('Error fetching invoices: $error');
      isLoading.value = false;
    });
  }

  void filterInvoices() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredInvoices.value = allInvoices;
    } else {
      filteredInvoices.value = allInvoices.where((invoice) {
        final number = invoice.invoiceNumber?.toLowerCase() ?? '';
        final clientName = invoice.buyerDetails?.name?.toLowerCase() ?? '';
        final clientPhone = invoice.buyerDetails?.mobile?.toLowerCase() ?? '';
        return number.contains(query) ||
            clientName.contains(query) ||
            clientPhone.contains(query);
      }).toList();
    }
  }

  void calculateAnalytics() {
    double total = 0.0;
    double paid = 0.0;
    double pending = 0.0;

    for (var invoice in allInvoices) {
      final status = invoice.status?.toLowerCase() ?? 'pending';
      final amount = invoice.grandTotal;

      if (status == 'paid') {
        paid += amount;
      } else {
        pending += amount;
      }
      total += amount;
    }

    totalReceivable.value = total;
    paidAmount.value = paid;
    pendingAmount.value = pending;
    invoiceCount.value = allInvoices.length;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
