import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductController extends GetxController {
  final productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final hsnController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();

  final category = 'Software'.obs;
  final unit = 'Pcs'.obs;
  final taxRate = '18%'.obs;
  final isTrackingInventory = false.obs;

  @override
  void onClose() {
    productNameController.dispose();
    descriptionController.dispose();
    hsnController.dispose();
    priceController.dispose();
    discountController.dispose();
    super.onClose();
  }

  void saveProduct() {
    // Placeholder for save logic
    Get.back();
  }
}
