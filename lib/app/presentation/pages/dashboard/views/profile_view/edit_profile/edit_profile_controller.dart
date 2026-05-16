import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/utils/app_constants.dart';
import '../../../../../../core/utils/app_snackbar.dart';
import '../profile_controller.dart';

class EditProfileController extends GetxController {
  final fullNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController(); 
  
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
        emailController.text = user.email ?? '';

        final doc = await FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          fullNameController.text = data['fullName'] ?? '';
          mobileController.text = data['mobile'] ?? '';
          businessNameController.text = data['businessName'] ?? '';
        }
      }
    } catch (e) {
      print('Error fetching edit profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (fullNameController.text.trim().isEmpty) {
      AppSnackbar.showError(title: 'Validation', message: 'Full name is required');
      return;
    }

    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firebase Auth display name
        await user.updateDisplayName(fullNameController.text.trim());

        // Update Firestore user document
        await FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(user.uid).update({
          'fullName': fullNameController.text.trim(),
          'businessName': businessNameController.text.trim(),
          'mobile': mobileController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local ProfileController state
        final profileController = Get.find<ProfileController>();
        profileController.userName.value = fullNameController.text.trim();
        profileController.businessName.value = businessNameController.text.trim();
        
        AppSnackbar.showSuccess(title: 'Success', message: 'Profile updated successfully!');
        Get.back();
      }
    } catch (e) {
      AppSnackbar.showError(title: 'Error', message: 'Failed to update profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    businessNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
