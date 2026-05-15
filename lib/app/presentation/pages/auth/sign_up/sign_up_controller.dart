import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/log_print_condition.dart';

import '../../../../core/utils/app_snackbar.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final isCheckTerm = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile Number is required';
    if (value.length < 10) return 'Enter a valid mobile number';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Confirm Password is required';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> signUp() async {
    if (formKey.currentState!.validate() && isCheckTerm.value) {
      isLoading.value = true;
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text);
        final uid = userCredential.user?.uid;
        if (uid == null) {
          throw Exception("User UID is null");
        }
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid ?? "").set({
          'uid': userCredential.user?.uid ?? "",
          'fullName': fullNameController.text.trim(),
          'businessName': businessNameController.text.trim(),
          'mobile': mobileController.text.trim(),
          'email': emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        AppSnackbar.showSuccess(title: 'Success', message: 'Account created successfully!');
        Get.back();
      } on FirebaseAuthException catch (e) {
        logPrint(e);
        AppSnackbar.showError(title: 'Error', message: e.message ?? 'An error occurred');
      } catch (e) {
        logPrint(e);
        AppSnackbar.showError(title: 'Error', message: e.toString());
      } finally {
        isLoading.value = false;
      }
    } else if (isCheckTerm.isFalse) {
      AppSnackbar.showError(title: 'Error', message: "Please accept the terms and conditions");
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    businessNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
