import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/services/cloudinary_service.dart';
import '../../../../../../core/utils/app_constants.dart';
import '../../../../../../core/utils/app_snackbar.dart';
import '../profile_controller.dart';

class EditProfileController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController(); // Email usually read-only in Firebase unless complex flow

  final profileImagePath = ''.obs;
  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final profileController = Get.find<ProfileController>();
    fullNameController.text = profileController.userName.value;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
      profileImagePath.value = user.photoURL ?? '';
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      AppSnackbar.showError(title: 'Error', message: 'Failed to pick image');
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
        String? imageUrl = profileImagePath.value;

        // Upload to Cloudinary if it's a local file
        if (profileImagePath.value.isNotEmpty && !profileImagePath.value.startsWith('http')) {
          imageUrl = await CloudinaryService.uploadImage(profileImagePath.value);
        }

        // Update Firebase Auth profile
        await user.updateDisplayName(fullNameController.text.trim());
        if (imageUrl != null) {
          await user.updatePhotoURL(imageUrl);
        }

        // Update Firestore user document
        await FirebaseFirestore.instance.collection(AppConstants.collectionUsers).doc(user.uid).update({'fullName': fullNameController.text.trim(), 'profileImageUrl': imageUrl, 'updatedAt': FieldValue.serverTimestamp()});

        // Update local ProfileController state
        final profileController = Get.find<ProfileController>();
        profileController.userName.value = fullNameController.text.trim();

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
    emailController.dispose();
    super.onClose();
  }
}
