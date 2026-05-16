import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/style_resource.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../../../data/models/business_model.dart';
import '../../../../../data/models/user_model.dart';

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
        // Fetch User basic info
        final userDoc = await FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(user.uid).get();
        if (userDoc.exists) {
          final userModel = UserModel.fromMap(userDoc.data()!, id: userDoc.id);
          userName.value = userModel.fullName ?? 'User';
          businessName.value = userModel.businessName ?? 'Business Name';
        }

        // Fetch Business specific details
        final businessDoc = await FirebaseFirestore.instance.collection(AppConstants.collectionBusinesses).doc(user.uid).get();
        if (businessDoc.exists) {
          final businessModel = BusinessModel.fromMap(businessDoc.data()!, id: businessDoc.id);
          businessType.value = businessModel.ownerName ?? 'Owner';

          if (businessModel.address != null) {
            final street = businessModel.address?.street ?? '';

            if (street.isNotEmpty) {
              location.value = street;
            } else {
              location.value = 'Location not set';
            }
          }
        }

        // Fetch Dynamic Counts
        final invoicesSnapshot = await FirebaseFirestore.instance.collection('invoices').where('userId', isEqualTo: user.uid).get();
        activeInvoices.value = invoicesSnapshot.docs.length;

        final customersSnapshot = await FirebaseFirestore.instance.collection('customers').where('userId', isEqualTo: user.uid).get();
        customers.value = customersSnapshot.docs.length;
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
