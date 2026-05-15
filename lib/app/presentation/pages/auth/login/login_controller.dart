import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/log_print_condition.dart';
import 'package:invoxa/app/routes/app_pages.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/app_snackbar.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text);
        AppSnackbar.showSuccess(title: 'Success', message: 'Logged in successfully');

        final isSetup = await FirestoreService().isBusinessSetupComplete();
        if (isSetup) {
          Get.offAllNamed(Routes.HOME);
        } else {
          Get.offAllNamed(Routes.BUSINESS_SETUP);
        }
      } on FirebaseAuthException catch (e) {
        logPrint(e);
        AppSnackbar.showError(title: 'Error', message: e.message ?? 'An error occurred');
      } catch (e) {
        logPrint(e);
        AppSnackbar.showError(title: 'Error', message: e.toString());
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
