import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/app_snackbar.dart';

class SettingsController extends GetxController {
  final isLoading = false.obs;

  // Invoice Settings
  final currency = '₹ INR - Indian Rupee'.obs;
  final invoicePrefix = 'INV-'.obs;

  final prefixController = TextEditingController(text: 'INV-');

  // Units of Measurement
  final units = <String>['Piece (pcs)', 'Unit', 'Item', 'Pair', 'Set', 'Packet', 'Inch', 'Feet (ft)', 'Square Feet (sq ft)'].obs;
  final customUnitController = TextEditingController();

  // Tax Settings
  final enableGST = true.obs;
  final cgstController = TextEditingController(text: '9');
  final sgstController = TextEditingController(text: '9');
  final igstController = TextEditingController(text: '18');

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  void addCustomUnit() {
    final unit = customUnitController.text.trim();
    if (unit.isNotEmpty && !units.contains(unit)) {
      units.add(unit);
      customUnitController.clear();
      AppSnackbar.showSuccess(title: 'Success', message: 'Custom unit added');
    }
  }

  void removeUnit(String unit) {
    if (units.length > 1) {
      units.remove(unit);
    }
  }

  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('settings').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          currency.value = data['currency'] ?? '₹ INR - Indian Rupee';
          prefixController.text = data['invoicePrefix'] ?? 'INV-';
          if (data['units'] != null) {
            units.value = List<String>.from(data['units']);
          }
          enableGST.value = data['enableGST'] ?? true;
          cgstController.text = (data['cgstRate'] ?? '9').toString();
          sgstController.text = (data['sgstRate'] ?? '9').toString();
          igstController.text = (data['igstRate'] ?? '18').toString();
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
          'units': units.toList(),
          'enableGST': enableGST.value,
          'cgstRate': cgstController.text,
          'sgstRate': sgstController.text,
          'igstRate': igstController.text,
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
    customUnitController.dispose();
    cgstController.dispose();
    sgstController.dispose();
    igstController.dispose();
    super.onClose();
  }
}
