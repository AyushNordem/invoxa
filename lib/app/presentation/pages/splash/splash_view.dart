import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/style_resource.dart';
import '../../../core/utils/assets_res.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background watermark simulation
          Positioned(
            top: -50,
            right: -50,
            child: Icon(Icons.receipt_long, size: 300, color: AppColors.borderGrey.withOpacity(0.3)),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Icon(Icons.description, size: 400, color: AppColors.borderGrey.withOpacity(0.2)),
          ),
          Center(
            child: FadeTransition(
              opacity: controller.animation,
              child: ScaleTransition(
                scale: controller.animation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 40, spreadRadius: 10),
                        ],
                      ),
                      child: Image.asset(AssetsRes.logo, width: 100, height: 100),
                    ),
                    const SizedBox(height: 32),
                    Text('Invoxa', style: StyleResource.instance.styleBold(fontSize: 48, color: AppColors.secondary)),
                    const SizedBox(height: 8),
                    Text('PRECISION INVOICING', style: StyleResource.instance.styleSemiBold(fontSize: 16, color: AppColors.greyText, letterSpacing: 4.0)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: controller.animation,
              child: Column(
                children: [
                  Container(
                    width: 250,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    alignment: Alignment.centerLeft,
                    child: AnimatedBuilder(
                      animation: controller.animation,
                      builder: (context, child) {
                        return Container(
                          width: 250 * controller.animation.value,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF944D)]),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Syncing your workspace...', style: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.greyText)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
