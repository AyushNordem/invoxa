import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/core/theme/app_sizes.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/style_resource.dart';
import 'dashboard_controller.dart';
import 'views/customer_view/customer_screen.dart';
import 'views/home_view/home_screen.dart';
import 'views/invoice_view/invoice_screen.dart';
import 'views/profile_view/profile_screen.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Obx(() => IndexedStack(index: controller.currentIndex.value, children: const [HomeScreen(), InvoiceScreen(), CustomerScreen(), ProfileScreen()])),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(context) {
    return Container(
      padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: 15, bottom: 15 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildNavItem(Icons.home_filled, 'Home', 0), _buildNavItem(Icons.description_outlined, 'Invoices', 1), _buildNavItem(Icons.group_outlined, 'Customers', 2), _buildNavItem(Icons.person_outline, 'Profile', 3)])),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = controller.currentIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changeTabIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(label, style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.primary)),
                ],
              ),
            )
          else
            Icon(icon, color: AppColors.greyText, size: 24),
        ],
      ),
    );
  }
}
