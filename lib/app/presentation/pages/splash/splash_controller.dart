import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/firestore_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    animation = CurvedAnimation(parent: animationController, curve: Curves.easeIn);

    animationController.forward();

    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final isSetup = await FirestoreService().isBusinessSetupComplete();
      if (isSetup) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.BUSINESS_SETUP);
      }
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
