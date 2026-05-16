import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/pages/dashboard/views/profile_view/settings/settings_controller.dart';

import '../../../../../../core/utils/app_constants.dart';
import '../../../../../../core/utils/app_snackbar.dart';
import '../../../../../../core/utils/invoice_number_generator.dart';
import '../../../../../../data/models/business_model.dart';
import '../../../../../../data/models/customer_model.dart';
import '../../../../../../data/models/invoice_model.dart';
import '../../../../../../data/models/setting_model.dart';

class AddInvoiceController extends GetxController {
  final isLoading = false.obs;
  final isButtonLoading = false.obs;

  // Seller (Business) Profile
  final sellerProfile = Rxn<BusinessModel>();
  final appSettings = Rxn<SettingModel>();

  // Buyer (Customer)
  final selectedCustomer = Rxn<CustomerModel>();
  final allCustomers = <CustomerModel>[].obs;

  // Invoice Header
  final invoiceNumber = ''.obs;
  final invoiceDate = DateTime.now().obs;
  final dueDate = DateTime.now().add(const Duration(days: 7)).obs;

  // Items
  final items = <InvoiceItem>[].obs;
  RxString selectedInvoiceUnit = "".obs;
  final units = <String>[].obs;

  // Tax Toggles
  final hasCGST = true.obs;
  final hasSGST = true.obs;
  final hasIGST = false.obs;
  final taxPercentage = 18.0.obs; // Default GST 18%

  // Controllers for header
  final invoiceNumberController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    SettingsController settingsController = Get.put(SettingsController());
    units.value = settingsController.units;
    selectedInvoiceUnit.value = units.first;
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Fetch Seller Details
      final bizDoc = await FirebaseFirestore.instance.collection(AppConstants.collectionBusinesses).doc(user.uid).get();
      if (bizDoc.exists) {
        sellerProfile.value = BusinessModel.fromMap(bizDoc.data()!);
      }

      // 2. Fetch App Settings (New)
      final settingsDoc = await FirebaseFirestore.instance.collection('settings').doc(user.uid).get();
      if (settingsDoc.exists) {
        final settings = SettingModel.fromMap(settingsDoc.data()!);
        appSettings.value = settings;

        // Initialize tax toggles from settings
        if (settings.taxSettings != null) {
          hasCGST.value = settings.taxSettings?.enableCGST ?? true;
          hasSGST.value = settings.taxSettings?.enableSGST ?? true;
          hasIGST.value = settings.taxSettings?.enableIGST ?? false;
          // Set default tax percentage from settings
          if (settings.taxSettings?.defaultTax != null) {
            taxPercentage.value = double.tryParse(settings.taxSettings!.defaultTax!) ?? 18.0;
          }
        }
      }
      // 2. Fetch All Customers for Buyer selection
      final custSnapshot = await FirebaseFirestore.instance.collection(AppConstants.collectionCustomers).where('userId', isEqualTo: user.uid).get();
      allCustomers.value = custSnapshot.docs.map((doc) => CustomerModel.fromMap(doc.data(), id: doc.id)).toList();

      // 3. Generate Invoice Number
      await generateInvoiceNumber();
    } catch (e) {
      AppSnackbar.showError(title: 'Error', message: 'Failed to load profile data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateInvoiceNumber() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance.collection('invoices').where('userId', isEqualTo: user.uid).get();

    int nextNum = 1;
    if (snapshot.docs.isNotEmpty) {
      int maxSeq = 0;
      for (var doc in snapshot.docs) {
        final invNum = doc.data()['invoiceNumber']?.toString() ?? '';
        final parts = invNum.split('-');
        if (parts.length >= 3) {
          final seq = int.tryParse(parts.last) ?? 0;
          if (seq > maxSeq) maxSeq = seq;
        }
      }
      nextNum = maxSeq + 1;
    }

    invoiceNumber.value = InvoiceNumberGenerator.generate(sequenceNumber: nextNum);
    invoiceNumberController.text = invoiceNumber.value;
  }

  // Calculation Logic
  double get subTotal => items.fold(0, (sum, item) => sum + item.amount);
  double get discountTotal => items.fold(0, (sum, item) => sum + (item.rate * item.quantity * (item.discount / 100)));

  double get taxAmountBase => subTotal - discountTotal;

  double get cgstAmount {
    if (!hasCGST.value) return 0;
    // Usually CGST + SGST = GST rate. So each is half.
    final rate = hasSGST.value ? (taxPercentage.value / 2) : taxPercentage.value;
    return taxAmountBase * (rate / 100);
  }

  double get sgstAmount {
    if (!hasSGST.value) return 0;
    final rate = hasCGST.value ? (taxPercentage.value / 2) : taxPercentage.value;
    return taxAmountBase * (rate / 100);
  }

  double get igstAmount {
    if (!hasIGST.value) return 0;
    return taxAmountBase * (taxPercentage.value / 100);
  }

  double get taxTotal => cgstAmount + sgstAmount + igstAmount;

  double get grandTotal => taxAmountBase + taxTotal;

  void addItem(InvoiceItem item) {
    items.add(item);
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void toggleCGST(bool value) {
    hasCGST.value = value;
    if (value) hasIGST.value = false;
  }

  void toggleSGST(bool value) {
    hasSGST.value = value;
    if (value) hasIGST.value = false;
  }

  void toggleIGST(bool value) {
    hasIGST.value = value;
    if (value) {
      hasCGST.value = false;
      hasSGST.value = false;
    }
  }

  void selectCustomer(CustomerModel customer) {
    selectedCustomer.value = customer;
  }

  Future<void> saveInvoice() async {
    try {
      // 1. Validation
      if (selectedCustomer.value == null) {
        AppSnackbar.showError(title: 'Customer Required', message: 'Please select a customer to continue');
        return;
      }

      if (items.isEmpty) {
        AppSnackbar.showError(title: 'Items Required', message: 'Please add at least one item');
        return;
      }

      if (sellerProfile.value == null) {
        AppSnackbar.showError(title: 'Profile Missing', message: 'Business profile not loaded');
        return;
      }

      isButtonLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 2. Construct Invoice Model with all current state data
      final invoice = InvoiceModel(
        userId: user.uid,
        invoiceNumber: invoiceNumber.value,
        date: invoiceDate.value,
        dueDate: dueDate.value,
        status: 'Pending',
        sellerDetails: sellerProfile.value,
        buyerDetails: selectedCustomer.value,
        items: items.toList(),
        subTotal: subTotal,
        discountTotal: discountTotal,
        taxTotal: taxTotal,
        grandTotal: grandTotal,
        hasCGST: hasCGST.value,
        hasSGST: hasSGST.value,
        hasIGST: hasIGST.value,
        taxPercentage: taxPercentage.value,
        notes: notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. Save to Firebase
      await FirebaseFirestore.instance.collection('invoices').add(invoice.toMap());
      AppSnackbar.showSuccess(title: 'Success', message: 'Invoice ${invoice.invoiceNumber} saved successfully');

      // 4. Return success result
      Get.back(result: true);
    } catch (e) {
      AppSnackbar.showError(title: 'Save Failed', message: e.toString());
    } finally {
      isButtonLoading.value = false;
    }
  }

  @override
  void onClose() {
    invoiceNumberController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
