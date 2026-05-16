import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/core/theme/app_sizes.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';
import 'package:invoxa/app/presentation/widgets/gradient_button.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../widgets/custom_text_field.dart';
import 'add_customer_controller.dart';

class AddCustomerView extends GetView<AddCustomerController> {
  const AddCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BaseView(
        title: controller.isEditing.value ? 'Edit Customer' : 'Add New Customer',
        bottomNavigationBar: Obx(() => GradientButton(text: controller.isEditing.value ? "Update Customer" : "Save Customer", onPressed: controller.saveAndSelect, isLoading: controller.isLoading.value).paddingSymmetric(horizontal: AppSpacing.md, vertical: AppRadius.sm)),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionHeader('BUSINESS INFORMATION'),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'Business Name', controller: controller.businessNameController, hint: 'e.g. Acme Corp', validator: (v) => controller.validateRequired(v, 'Business Name')),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'Contact Person', controller: controller.contactPersonController, hint: 'Full Name', validator: (v) => controller.validateRequired(v, 'Contact Person')),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'Email Address (Optional)', controller: controller.emailController, hint: 'name@company.com', validator: controller.validateEmail),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'Phone Number', controller: controller.phoneController, hint: '+1 (555) 000-0000', validator: controller.validatePhone, keyboardType: TextInputType.phone),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'GSTIN (Optional)', controller: controller.gstinController, hint: '22AAAAA0000A1Z5', validator: controller.validateGST),
                const SizedBox(height: AppRadius.lg),
                Row(
                  children: [
                    _buildSectionHeader('BILLING ADDRESS'),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'Street Address', controller: controller.streetController, hint: 'Suite, Floor, Building Name', validator: (v) => controller.validateRequired(v, 'Street Address')),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'City', controller: controller.cityController, hint: 'City', validator: (v) => controller.validateRequired(v, 'City')),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'State', controller: controller.stateController, hint: 'State', validator: (v) => controller.validateRequired(v, 'State')),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(label: 'ZIP Code (Optional)', controller: controller.zipController, hint: '10001', validator: controller.validateZip, keyboardType: TextInputType.number),
                const SizedBox(height: AppRadius.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary));
  }
}
