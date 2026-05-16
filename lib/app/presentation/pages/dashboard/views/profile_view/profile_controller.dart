import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/style_resource.dart';
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

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
        content: Text('Are you sure you want to logout from Invoxa?', style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.greyText)),
          ),
          ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Logout', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }
}
