import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/app_snackbar.dart';

class SettingsController extends GetxController {
  final isLoading = false.obs;

  // Invoice Settings
  final currency = 'INR - Indian Rupee'.obs;
  final invoicePrefix = 'INV-'.obs;
  final financialYear = 'Apr - Mar'.obs;

  final prefixController = TextEditingController(text: 'INV-');

  // Tax Settings
  final enableGST = true.obs;
  final gstRate = 18.0.obs;
  final enableVAT = false.obs;
  final vatRateController = TextEditingController(text: '5');

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('settings').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          currency.value = data['currency'] ?? 'INR - Indian Rupee';
          prefixController.text = data['invoicePrefix'] ?? 'INV-';
          financialYear.value = data['financialYear'] ?? 'Apr - Mar';
          enableGST.value = data['enableGST'] ?? true;
          gstRate.value = (data['gstRate'] ?? 18.0).toDouble();
          enableVAT.value = data['enableVAT'] ?? false;
          vatRateController.text = (data['vatRate'] ?? 5).toString();
        }
      }
    } catch (e) {
      print('Error fetching settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final settingsData = {
          'currency': currency.value,
          'invoicePrefix': prefixController.text.trim(),
          'financialYear': financialYear.value,
          'enableGST': enableGST.value,
          'gstRate': gstRate.value,
          'enableVAT': enableVAT.value,
          'vatRate': int.tryParse(vatRateController.text) ?? 5,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('settings').doc(user.uid).set(settingsData, SetOptions(merge: true));
        AppSnackbar.showSuccess(title: 'Success', message: 'Settings saved successfully!');
      }
    } catch (e) {
      AppSnackbar.showError(title: 'Error', message: 'Failed to save settings');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    prefixController.dispose();
    vatRateController.dispose();
    super.onClose();
  }
}
