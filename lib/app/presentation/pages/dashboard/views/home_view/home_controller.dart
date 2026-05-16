import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_constants.dart';

class HomeController extends GetxController {
  final userName = 'User'.obs;
  final isLoading = true.obs;
  final totalRevenue = 42850.0.obs;
  final pendingAmount = 12400.0.obs;
  final billingGrowth = 12.0.obs;

  final recentActivities = <Map<String, dynamic>>[
    {'name': 'Acme Corp.', 'id': 'Inv #2024-001', 'amount': 2450.0, 'status': 'PAID'},
    {'name': 'Global Tech', 'id': 'Inv #2024-002', 'amount': 1120.0, 'status': 'PENDING'},
    {'name': 'Design Studio', 'id': 'Inv #2023-142', 'amount': 850.0, 'status': 'OVERDUE'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(user.uid).get();

        if (doc.exists) {
          userName.value = doc.data()?['fullName'] ?? 'User';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
