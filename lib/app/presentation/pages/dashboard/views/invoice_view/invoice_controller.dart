import 'package:get/get.dart';

class InvoiceController extends GetxController {
  final totalReceivable = 42850.0.obs;
  final paidAmount = 38200.0.obs;
  final pendingAmount = 4600.0.obs;
  final invoiceCount = 24.obs;

  final invoices = <Map<String, dynamic>>[
    {
      'id': 'Invoice #2024-001',
      'client': 'Acme Corp',
      'date': 'Oct 24, 2024',
      'amount': 2450.0,
      'status': 'PAID',
    },
    {
      'id': 'Invoice #2024-002',
      'client': 'Global Tech Inc.',
      'date': 'Oct 26, 2024',
      'amount': 1120.50,
      'status': 'PENDING',
    },
    {
      'id': 'Invoice #2024-003',
      'client': 'Creative Studio',
      'date': 'Oct 12, 2024',
      'amount': 890.0,
      'status': 'OVERDUE',
    },
    {
      'id': 'Invoice #2024-004',
      'client': 'Nebula Systems',
      'date': 'Oct 10, 2024',
      'amount': 5400.0,
      'status': 'PAID',
    },
  ].obs;
}
