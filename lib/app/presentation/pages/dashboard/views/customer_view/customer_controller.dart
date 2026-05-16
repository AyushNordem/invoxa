import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/log_print_condition.dart';

import '../../../../../core/utils/app_constants.dart';
import '../../../../../data/models/customer_model.dart';

class CustomerController extends GetxController {
  final isLoading = false.obs;
  final customers = <CustomerModel>[].obs;
  final filteredCustomers = <CustomerModel>[].obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();

    // Setup search listener
    searchController.addListener(() {
      filterCustomers(searchController.text);
    });
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance.collection(AppConstants.collectionCustomers).where('userId', isEqualTo: user.uid).get();
        
        final fetchedCustomers = snapshot.docs.map((doc) => CustomerModel.fromMap(doc.data(), id: doc.id)).toList();
        
        // Sort client-side to avoid Firestore composite index requirement
        fetchedCustomers.sort((a, b) {
          final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA); // Newest first
        });

        customers.value = fetchedCustomers;
        filteredCustomers.value = customers;
      }
    } catch (e) {
      logPrint('Error fetching customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterCustomers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCustomers.value = customers;
    } else {
      filteredCustomers.value = customers.where((customer) {
        final nameMatch = customer.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final phoneMatch = customer.mobile?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final contactMatch = customer.contactPerson?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return nameMatch || phoneMatch || contactMatch;
      }).toList();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
