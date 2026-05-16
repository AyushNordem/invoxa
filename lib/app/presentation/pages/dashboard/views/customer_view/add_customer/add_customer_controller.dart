import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCustomerController extends GetxController {
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

  void saveAndSelect() {
    // Placeholder for save logic
    Get.back();
  }
}
