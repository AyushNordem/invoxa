import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_constants.dart';

class ProfileController extends GetxController {
  final userName = 'User'.obs;
  final businessName = 'Invoxa Solutions'.obs;
  final businessType = 'Software & Technology Services'.obs;
  final location = 'Mumbai, India'.obs;
  final activeInvoices = 12.obs;
  final customers = 48.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(user.uid).get();
        if (doc.exists) {
          userName.value = doc.data()?['fullName'] ?? 'User';
        }

        // Fetch business details if available
        final businessDoc = await FirebaseFirestore.instance.collection(AppConstants.collectionBusinesses).doc(user.uid).get();
        if (businessDoc.exists) {
          businessName.value = businessDoc.data()?['businessName'] ?? 'Business Name';
        }
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }
}
