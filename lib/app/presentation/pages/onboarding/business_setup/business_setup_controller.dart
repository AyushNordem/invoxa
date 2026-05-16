import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/business_model.dart';
import '../../../../routes/app_pages.dart';

class BusinessSetupController extends GetxController {
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['isEditing'] == true) {
      isEditing.value = true;
      fetchExistingData();
    }
  }

  Future<void> fetchExistingData() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('businesses').doc(user.uid).get();
        if (doc.exists) {
          final businessModel = BusinessModel.fromMap(doc.data()!, id: doc.id);

          businessNameController.text = businessModel.businessName ?? '';
          ownerNameController.text = businessModel.ownerName ?? '';
          emailController.text = businessModel.email ?? '';
          mobileController.text = businessModel.mobile ?? '';
          websiteController.text = businessModel.website ?? '';
          logoPath.value = businessModel.logoUrl ?? '';
          signaturePath.value = businessModel.signatureUrl ?? '';

          if (businessModel.address != null) {
            addressController.text = businessModel.address?.street ?? '';
            stateValue.value = businessModel.address?.state ?? "";
            cityController.text = businessModel.address?.city ?? '';
            pincodeController.text = businessModel.address?.pincode ?? '';
          }

          if (businessModel.bankDetails != null) {
            accountHolderController.text = businessModel.bankDetails?.accountHolder ?? '';
            bankNameController.text = businessModel.bankDetails?.bankName ?? '';
            accountNumberController.text = businessModel.bankDetails?.accountNumber ?? '';
            ifscController.text = businessModel.bankDetails?.ifsc ?? '';
            branchController.text = businessModel.bankDetails?.branch ?? '';
          }

          gstController.text = businessModel.gstNumber ?? '';
          taxNumberController.text = businessModel.taxNumber ?? '';
        }
      }
    } catch (e) {
      print('Error fetching business data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Step 1: Business Info
  final formKey1 = GlobalKey<FormState>();
  final logoPath = ''.obs;
  final signaturePath = ''.obs;
  final businessNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final websiteController = TextEditingController();

  // Step 2: Address Details
  final formKey2 = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final stateValue = RxnString();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  // Step 3: Bank Details
  final formKey3 = GlobalKey<FormState>();
  final accountHolderController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final branchController = TextEditingController();

  // Step 4: Tax & Invoice Settings
  final formKey4 = GlobalKey<FormState>();
  final gstController = TextEditingController();
  final taxNumberController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(bool isLogo) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (isLogo) {
          logoPath.value = image.path;
        } else {
          signaturePath.value = image.path;
        }
      }
    } catch (e) {
      AppSnackbar.showError(title: 'Error', message: 'Failed to pick image');
    }
  }

  void nextStep() {
    bool canProceed = false;
    if (currentStep.value == 0) {
      canProceed = formKey1.currentState?.validate() ?? false;
    } else if (currentStep.value == 1) {
      canProceed = formKey2.currentState?.validate() ?? false;
    } else if (currentStep.value == 2) {
      canProceed = formKey3.currentState?.validate() ?? false;
    }

    if (canProceed) {
      currentStep.value++;
    } else {
      AppSnackbar.showError(title: 'Validation', message: 'Please complete the required fields correctly.');
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> saveAndContinue() async {
    if (formKey1.currentState?.validate() ?? false) {
      if (logoPath.value.isEmpty) {
        AppSnackbar.showError(title: 'Validation', message: 'Please upload your business logo.');
        return;
      }
      isLoading.value = true;
      try {
        String? logoUrl;
        String? signatureUrl;

        // Upload images to Cloudinary
        if (logoPath.value.isNotEmpty && !logoPath.value.startsWith('http')) {
          logoUrl = await CloudinaryService.uploadImage(logoPath.value);
        } else {
          logoUrl = logoPath.value;
        }

        if (signaturePath.value.isNotEmpty && !signaturePath.value.startsWith('http')) {
          signatureUrl = await CloudinaryService.uploadImage(signaturePath.value);
        } else {
          signatureUrl = signaturePath.value;
        }

        // Prepare business data using model
        final businessModel = BusinessModel(
          businessName: businessNameController.text.trim(),
          ownerName: ownerNameController.text.trim(),
          email: emailController.text.trim(),
          mobile: mobileController.text.trim(),
          website: websiteController.text.trim(),
          gstNumber: gstController.text.trim(),
          taxNumber: taxNumberController.text.trim(),
          logoUrl: logoUrl,
          signatureUrl: signatureUrl,
          address: AddressInfo(street: addressController.text.trim(), state: stateValue.value, city: cityController.text.trim(), pincode: pincodeController.text.trim()),
          bankDetails: BankDetails(accountHolder: accountHolderController.text.trim(), bankName: bankNameController.text.trim(), accountNumber: accountNumberController.text.trim(), ifsc: ifscController.text.trim(), branch: branchController.text.trim()),
        );

        // Save to Firestore using toMap()
        await _firestoreService.saveBusinessDetails(businessModel.toMap());

        AppSnackbar.showSuccess(title: 'Success', message: 'Business setup completed!');
        Get.offAllNamed(Routes.HOME);
      } catch (e) {
        AppSnackbar.showError(title: 'Error', message: e.toString());
      } finally {
        isLoading.value = false;
      }
    } else {
      AppSnackbar.showError(title: 'Validation', message: 'Please complete the required fields correctly.');
    }
  }

  String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email address';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length < 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  String? validateGST(String? value) {
    if (value == null || value.isEmpty) return null; // Optional but if provided should be valid? Actually user might want it required.
    // Basic GST format: 22AAAAA0000A1Z5
    if (value.isNotEmpty && value.length != 15) return 'GST number must be 15 characters';
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return 'Pincode is required';
    if (value.length != 6) return 'Pincode must be 6 digits';
    if (!GetUtils.isNumericOnly(value)) return 'Pincode must be numeric';
    return null;
  }

  @override
  void onClose() {
    businessNameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    websiteController.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    accountHolderController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    branchController.dispose();
    gstController.dispose();
    taxNumberController.dispose();
    super.onClose();
  }
}
