import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/style_resource.dart';
import '../../../../../data/models/customer_model.dart';
import '../../../../../routes/app_pages.dart';
import 'customer_controller.dart';

class CustomerScreen extends GetView<CustomerController> {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: "Customers",
      showBackButton: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.ADD_CUSTOMER),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person_add_alt_1, color: AppColors.white, size: 28),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.xl),
            _buildDirectoryHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildCustomerList(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                hintStyle: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText),
                border: InputBorder.none,
              ),
              style: StyleResource.instance.styleMedium(fontSize: 15, color: AppColors.black),
            ),
          ),
          Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.greyText, size: 18),
                    onPressed: () => controller.searchController.clear(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CLIENT DIRECTORY', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary.withOpacity(0.6)).copyWith(letterSpacing: 1)),
            const SizedBox(height: 4),
            Obx(() => Text('${controller.filteredCustomers.length} Total Customers', style: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.primary))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Icon(Icons.sort, color: AppColors.primary, size: 14),
              const SizedBox(width: 6),
              Text('Recent', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerList() {
    return Obx(
      () => controller.isLoading.value
          ? const Center(
              child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()),
            )
          : controller.filteredCustomers.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredCustomers.length,
              itemBuilder: (context, index) {
                return _buildCustomerCard(controller.filteredCustomers[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.person_search_outlined, size: 64, color: AppColors.greyText.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(controller.searchQuery.value.isEmpty ? 'No customers added yet' : 'No customers found for "${controller.searchQuery.value}"', style: StyleResource.instance.styleMedium(fontSize: 16, color: AppColors.greyText)),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header Section
          InkWell(
            onTap: () => Get.toNamed(Routes.ADD_CUSTOMER, arguments: {'customer': customer}),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.03),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryBorder]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text((customer.name ?? '?').substring(0, 1).toUpperCase(), style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.name ?? 'Unknown Business', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
                        Text(customer.contactPerson ?? 'No Contact Person', style: StyleResource.instance.styleMedium(fontSize: 13, color: AppColors.greyText)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.greyText),
                ],
              ),
            ),
          ),
          // Details Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(Icons.phone_outlined, customer.mobile ?? 'N/A'),
                const SizedBox(height: AppRadius.xs),
                _buildInfoRow(Icons.location_on, '${customer.address?.street ?? ''}, ${customer.address?.city ?? ''}, ${customer.address?.state ?? ''} ${customer.address?.zipCode ?? ''}' ?? 'N/A'),
                if (customer.gstNumber != null && customer.gstNumber!.isNotEmpty) ...[const SizedBox(height: AppRadius.xs), _buildInfoRow(Icons.description_outlined, 'GST: ${customer.gstNumber}')],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: onTap != null ? AppColors.primary : AppColors.secondary.withOpacity(0.8))),
            ),
            if (onTap != null) const Icon(Icons.call, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
