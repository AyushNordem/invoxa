import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../widgets/custom_text_field.dart';
import 'edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Edit Profile Details',
      child: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update your general and contact information.', style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText)),
                    const SizedBox(height: 32),

                    _buildSectionLabel('GENERAL INFORMATION'),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Full Name', hint: 'e.g. Alex Johnson', controller: controller.fullNameController, prefixIcon: Icons.person_outline),
                    const SizedBox(height: 20),
                    CustomTextField(label: 'Business Name', hint: 'e.g. Acme Solutions', controller: controller.businessNameController, prefixIcon: Icons.business_outlined),

                    const SizedBox(height: 32),
                    _buildSectionLabel('CONTACT DETAILS'),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Mobile Number', hint: '+1 (555) 000-0000', controller: controller.mobileController, prefixIcon: Icons.phone_iphone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),
                    CustomTextField(label: 'Email Address (Read Only)', hint: 'email@example.com', controller: controller.emailController, prefixIcon: Icons.email_outlined, readOnly: true),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Update Profile', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: StyleResource.instance.styleSemiBold(fontSize: 13, color: AppColors.primary, letterSpacing: 1.2));
  }
}
