import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddInvoiceController extends GetxController {
  final invoiceNumberController = TextEditingController(text: 'INV-2024-005');
  final invoiceDateController = TextEditingController();
  final dueDateController = TextEditingController();
  final paymentMethod = 'Bank Transfer'.obs;
  final placeOfSupply = ''.obs;
  final isExistingCustomer = true.obs;

  final items = <Map<String, dynamic>>[
    {
      'title': 'UI/UX Design Package',
      'description': 'Professional dashboard & mobile app design',
      'qty': '1 / Monthly',
      'price': 2400.0,
    },
    {
      'title': 'Brand Identity Audit',
      'description': 'Visual language and accessibility review',
      'qty': '1 / Flat',
      'price': 850.0,
    },
  ].obs;

  double get subtotal => items.fold(0, (sum, item) => sum + (item['price'] as double));
  double get tax => subtotal * 0.18;
  double get total => subtotal + tax;

  @override
  void onClose() {
    invoiceNumberController.dispose();
    invoiceDateController.dispose();
    dueDateController.dispose();
    super.onClose();
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void addItem() {
    // Placeholder for adding item logic
  }
}
