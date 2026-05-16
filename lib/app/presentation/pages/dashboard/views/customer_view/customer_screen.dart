import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/style_resource.dart';
import '../../../../../routes/app_pages.dart';
import 'customer_controller.dart';

class CustomerScreen extends GetView<CustomerController> {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildAppBar(),
            const SizedBox(height: AppSpacing.lg),
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.lg),
            _buildSummaryRow(),
            const SizedBox(height: AppSpacing.xl),
            _buildDirectoryHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildCustomerList(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.ADD_CUSTOMER),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person_add_alt_1, color: AppColors.white, size: 28),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex')),
        Text('Customers', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.primary)),
        const Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 24),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.greyText, size: 20),
          const SizedBox(width: 12),
          Text('Search customers...', style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('TOTAL REVENUE', '\$142.8k')),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('ACTIVE CLIENT', '48')),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value) {
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
          Text(value, style: StyleResource.instance.styleBold(fontSize: 22, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildDirectoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('CLIENT DIRECTORY', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary.withOpacity(0.6))),
        Text('Sort: Recent', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildCustomerList() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.customers.length,
        itemBuilder: (context, index) {
          return _buildCustomerCard(controller.customers[index]);
        },
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final status = customer['status'];
    Color statusColor;
    Color bgColor;

    if (status == 'Active') {
      statusColor = AppColors.primary;
      bgColor = AppColors.primarySoft;
    } else if (status == 'New') {
      statusColor = Colors.blue;
      bgColor = Colors.blue.withOpacity(0.1);
    } else {
      statusColor = AppColors.greyText;
      bgColor = AppColors.borderGrey.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer['name'], style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
                  Text(customer['phone'], style: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.greyText)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: StyleResource.instance.styleBold(fontSize: 10, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last Purchase', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
                  Text(customer['lastPurchase'], style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total Business', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
                  Text('\$${(customer['totalBusiness'] as double).toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
