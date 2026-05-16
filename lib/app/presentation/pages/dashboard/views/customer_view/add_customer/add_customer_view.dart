import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';
import 'add_customer_controller.dart';

class AddCustomerView extends GetView<AddCustomerController> {
  const AddCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.secondary),
          onPressed: () => Get.back(),
        ),
        title: Text('Add New Customer', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFFF7F0), borderRadius: BorderRadius.circular(20)),
              child: Text('STEP 2: CUSTOMER DETAILS', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary)),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('BUSINESS INFORMATION'),
            const SizedBox(height: 16),
            _buildLabel('Business Name'),
            _buildTextField(controller: controller.businessNameController, hint: 'e.g. Acme Corp'),
            const SizedBox(height: 16),
            _buildLabel('Contact Person'),
            _buildTextField(controller: controller.contactPersonController, hint: 'Full Name'),
            const SizedBox(height: 16),
            _buildLabel('Email Address'),
            _buildTextField(controller: controller.emailController, hint: 'name@company.com'),
            const SizedBox(height: 16),
            _buildLabel('Phone Number'),
            _buildTextField(controller: controller.phoneController, hint: '+1 (555) 000-0000'),
            const SizedBox(height: 16),
            _buildLabel('GSTIN (Optional)'),
            _buildTextField(controller: controller.gstinController, hint: '22AAAAA0000A1Z5'),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildSectionHeader('BILLING ADDRESS'),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_outlined, color: AppColors.greyText, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Street Address'),
            _buildTextField(controller: controller.streetController, hint: 'Suite, Floor, Building Name'),
            const SizedBox(height: 16),
            _buildLabel('City'),
            _buildTextField(controller: controller.cityController, hint: 'City'),
            const SizedBox(height: 16),
            _buildLabel('State'),
            _buildTextField(controller: controller.stateController, hint: 'State'),
            const SizedBox(height: 16),
            _buildLabel('ZIP Code'),
            _buildTextField(controller: controller.zipController, hint: '10001'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.saveAndSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Save & Select', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
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
    return Text(title, style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary.withOpacity(0.6)));
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.greyText)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
