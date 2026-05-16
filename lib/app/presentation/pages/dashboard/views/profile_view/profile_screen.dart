import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/style_resource.dart';
import '../../../../../routes/app_pages.dart';
import 'profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildAppBar(),
            const SizedBox(height: AppSpacing.xl),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildEditButton(),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildMenuSection(),
            const SizedBox(height: 16),
            _buildLogoutButton(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex')),
        Text('Invoxa', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.primary)),
        const Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 24),
      ],
    );
  }

  Widget _buildHeader() {
    return Obx(
      () => Column(
        children: [
          Text(controller.businessName.value, style: StyleResource.instance.styleBold(fontSize: 24, color: AppColors.secondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFF7F0), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text('Verified Business', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(controller.businessType.value, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.greyText)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.greyText, size: 14),
              const SizedBox(width: 4),
              Text(controller.location.value, style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Edit Profile', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('ACTIVE INVOICES', controller.activeInvoices.value.toString())),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('CUSTOMERS', controller.customers.value.toString())),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.greyText.withOpacity(0.6))),
          const SizedBox(height: 8),
          Text(value, style: StyleResource.instance.styleBold(fontSize: 22, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadius.card),
      child: Column(
        children: [
          _buildMenuItem(Icons.business_outlined, 'Business Information', onTap: () => Get.toNamed(Routes.BUSINESS_SETUP, arguments: {'isEditing': true})),
          _buildMenuItem(Icons.lock_outline, 'Update Password', onTap: () => Get.toNamed(Routes.UPDATE_PASSWORD)),
          _buildMenuItem(Icons.settings_outlined, 'Settings'),
          _buildMenuItem(Icons.shield_outlined, 'Privacy Policy'),
          _buildMenuItem(Icons.description_outlined, 'Terms & Conditions'),
          _buildMenuItem(Icons.help_outline, 'Help & Support', isLast: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap, bool isLast = false}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.greyText, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadius.card),
      child: InkWell(
        onTap: controller.logout,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.logout, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 16),
              Text('Logout', style: StyleResource.instance.styleBold(fontSize: 14, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
