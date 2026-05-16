import 'package:get/get.dart';

class CustomerController extends GetxController {
  final totalRevenue = 142800.0.obs;
  final activeClients = 48.obs;

  final customers = <Map<String, dynamic>>[
    {
      'name': 'Acme Corp',
      'phone': '+1 (555) 000-1234',
      'status': 'Active',
      'lastPurchase': 'Oct 24, 2024',
      'totalBusiness': 12450.0,
    },
    {
      'name': 'Global Tech Solutions',
      'phone': '+1 (555) 234-5678',
      'status': 'New',
      'lastPurchase': 'Oct 12, 2024',
      'totalBusiness': 8120.50,
    },
    {
      'name': 'Nebula Ventures',
      'phone': '+44 20 7946 0958',
      'status': 'Active',
      'lastPurchase': 'Sept 28, 2024',
      'totalBusiness': 45900.00,
    },
    {
      'name': 'Sterling & Co.',
      'phone': '+1 (555) 987-6543',
      'status': 'Inactive',
      'lastPurchase': 'Aug 15, 2024',
      'totalBusiness': 2300.00,
    },
  ].obs;
}
