import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/app_constants.dart';
import '../../../../../../core/utils/app_snackbar.dart';
import '../../../../../../data/models/customer_model.dart';

class AddCustomerController extends GetxController {
  final isEditing = false.obs;
  CustomerModel? existingCustomer;
  
  // Business Info
  final businessNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final gstinController = TextEditingController();

  // Billing Address
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['customer'] != null) {
      isEditing.value = true;
      existingCustomer = Get.arguments['customer'];
      _populateFields();
    }
  }

  void _populateFields() {
    if (existingCustomer == null) return;
    
    businessNameController.text = existingCustomer!.name ?? '';
    contactPersonController.text = existingCustomer!.contactPerson ?? '';
    emailController.text = existingCustomer!.email ?? '';
    phoneController.text = existingCustomer!.mobile ?? '';
    gstinController.text = existingCustomer!.gstNumber ?? '';
    
    if (existingCustomer!.address != null) {
      streetController.text = existingCustomer!.address!.street ?? '';
      cityController.text = existingCustomer!.address!.city ?? '';
      stateController.text = existingCustomer!.address!.state ?? '';
      zipController.text = existingCustomer!.address!.zipCode ?? '';
    }
  }

  @override
  void onClose() {
    businessNameController.dispose();
    contactPersonController.dispose();
    emailController.dispose();
    phoneController.dispose();
    gstinController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    super.onClose();
  }

  String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    if (!GetUtils.isEmail(value)) return 'Enter a valid email address';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length < 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  String? validateGST(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    if (value.length != 15) return 'GST number must be 15 characters';
    return null;
  }

  String? validateZip(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    if (value.length != 6) return 'ZIP Code must be 6 digits';
    return null;
  }

  final isLoading = false.obs;

  void saveAndSelect() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final name = businessNameController.text.trim();
        final mobile = phoneController.text.trim();

        // Check for duplicates ONLY if not editing or if name/mobile changed
        if (!isEditing.value || (name != existingCustomer?.name || mobile != existingCustomer?.mobile)) {
          final nameCheck = await FirebaseFirestore.instance.collection(AppConstants.collectionCustomers).where('userId', isEqualTo: user.uid).where('name', isEqualTo: name).get();

          if (nameCheck.docs.isNotEmpty && (!isEditing.value || nameCheck.docs.first.id != existingCustomer?.id)) {
            isLoading.value = false;
            AppSnackbar.showError(title: 'Duplicate Found', message: 'A customer with this name already exists.');
            return;
          }

          final mobileCheck = await FirebaseFirestore.instance.collection(AppConstants.collectionCustomers).where('userId', isEqualTo: user.uid).where('mobile', isEqualTo: mobile).get();

          if (mobileCheck.docs.isNotEmpty && (!isEditing.value || mobileCheck.docs.first.id != existingCustomer?.id)) {
            isLoading.value = false;
            AppSnackbar.showError(title: 'Duplicate Found', message: 'A customer with this phone number already exists.');
            return;
          }
        }

        final customer = CustomerModel(
          userId: user.uid,
          name: name,
          contactPerson: contactPersonController.text.trim(),
          email: emailController.text.trim(),
          mobile: mobile,
          gstNumber: gstinController.text.trim(),
          address: CustomerAddress(
            street: streetController.text.trim(),
            city: cityController.text.trim(),
            state: stateController.text.trim(),
            zipCode: zipController.text.trim(),
          ),
          createdAt: isEditing.value ? existingCustomer?.createdAt : DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (isEditing.value && existingCustomer?.id != null) {
          await FirebaseFirestore.instance.collection(AppConstants.collectionCustomers).doc(existingCustomer!.id).update(customer.toMap());
          AppSnackbar.showSuccess(title: 'Success', message: 'Customer updated successfully!');
        } else {
          await FirebaseFirestore.instance.collection(AppConstants.collectionCustomers).add(customer.toMap());
          AppSnackbar.showSuccess(title: 'Success', message: 'Customer added successfully!');
        }

        isLoading.value = false;
        Navigator.of(Get.context!).pop();
      } catch (e) {
        isLoading.value = false;
        AppSnackbar.showError(title: 'Error', message: 'Failed to save customer: ${e.toString()}');
      }
    }
  }
}
