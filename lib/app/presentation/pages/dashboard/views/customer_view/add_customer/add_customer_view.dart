import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/core/theme/app_sizes.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../widgets/custom_text_field.dart';
import 'add_customer_controller.dart';

class AddCustomerView extends GetView<AddCustomerController> {
  const AddCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Add New Customer',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildSectionHeader('BUSINESS INFORMATION'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'Business Name', controller: controller.businessNameController, hint: 'e.g. Acme Corp'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'Contact Person', controller: controller.contactPersonController, hint: 'Full Name'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'Email Address', controller: controller.emailController, hint: 'name@company.com'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'Phone Number', controller: controller.phoneController, hint: '+1 (555) 000-0000'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'GSTIN (Optional)', controller: controller.gstinController, hint: '22AAAAA0000A1Z5'),
            const SizedBox(height: AppRadius.lg),
            Row(
              children: [
                _buildSectionHeader('BILLING ADDRESS'),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'Street Address', controller: controller.streetController, hint: 'Suite, Floor, Building Name'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'City', controller: controller.cityController, hint: 'City'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'State', controller: controller.stateController, hint: 'State'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(label: 'ZIP Code', controller: controller.zipController, hint: '10001'),
            const SizedBox(height: AppRadius.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.saveAndSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Save & Select',
                      style: StyleResource.instance.styleBold(fontSize: AppSpacing.md, color: AppColors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary));
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.greyText)),
    );
  }
}
