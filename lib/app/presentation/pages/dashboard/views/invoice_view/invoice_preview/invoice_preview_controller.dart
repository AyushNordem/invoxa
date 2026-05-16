import 'package:get/get.dart';

class InvoicePreviewController extends GetxController {
  final invoiceData = {
    'id': 'INV-2024-001',
    'status': 'DRAFT',
    'clientName': 'Acme Corp',
    'clientEmail': 'billing@acme.com',
    'clientAddress': '456 Enterprise Way,\nSan Francisco, CA',
    'date': 'Oct 24, 2024',
    'dueDate': 'Nov 10, 2024',
    'items': [
      {
        'title': 'UI/UX Design Package',
        'desc': 'Standard mobile app design',
        'qty': 1,
        'price': 2400.0,
      },
      {
        'title': 'Brand Identity Audit',
        'desc': 'Comprehensive style review',
        'qty': 1,
        'price': 850.0,
      },
    ],
    'subtotal': 3250.0,
    'tax': 585.0,
    'total': 3835.0,
    'amountInWords': 'Three Thousand Eight Hundred Thirty Five Dollars Only.',
    'bankDetails': {
      'bank': 'HDFC',
      'account': '50200012345678',
      'ifsc': 'HDFC0001234',
    }
  }.obs;
}
