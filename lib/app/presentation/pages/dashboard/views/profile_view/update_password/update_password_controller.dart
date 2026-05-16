import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/app_snackbar.dart';

class UpdatePasswordController extends GetxController {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscureCurrent = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  final formKey = GlobalKey<FormState>();

  Future<void> updatePassword() async {
    if (formKey.currentState?.validate() ?? false) {
      if (newPasswordController.text != confirmPasswordController.text) {
        AppSnackbar.showError(title: 'Error', message: 'New passwords do not match');
        return;
      }

      try {
        isLoading.value = true;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          // Re-authenticate user
          AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: currentPasswordController.text);

          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(newPasswordController.text);

          AppSnackbar.showSuccess(title: 'Success', message: 'Password updated successfully!');
          Get.back();
        }
      } on FirebaseAuthException catch (e) {
        AppSnackbar.showError(title: 'Error', message: e.message ?? 'Failed to update password');
      } catch (e) {
        AppSnackbar.showError(title: 'Error', message: 'An unexpected error occurred');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
