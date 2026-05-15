import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';

class BusinessSetupController extends GetxController {
  final currentStep = 0.obs;
  final isLoading = false.obs;

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
  final currencyValue = 'INR'.obs;
  final defaultTaxController = TextEditingController();
  final enableCGST = true.obs;
  final enableSGST = true.obs;
  final enableIGST = false.obs;

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

  Future<void> saveAndContinue() async {
    if (formKey4.currentState?.validate() ?? false) {
      isLoading.value = true;
      try {
        // TODO: Upload images to Firebase Storage
        // TODO: Save business data to Firestore
        await Future.delayed(const Duration(seconds: 2));
        AppSnackbar.showSuccess(title: 'Success', message: 'Business setup completed!');
        Get.offAllNamed('/dashboard'); // placeholder route
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
    defaultTaxController.dispose();
    super.onClose();
  }
}
