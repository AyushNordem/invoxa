import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../widgets/custom_text_field.dart';
import 'update_password_controller.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  const UpdatePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Update Password',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Your Password', style: StyleResource.instance.styleBold(fontSize: 24, color: AppColors.secondary)),
              const SizedBox(height: 8),
              Text('For your security, please do not share your password with others.', style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText)),
              const SizedBox(height: 32),
              Obx(
                () => CustomTextField(
                  label: 'Current Password',
                  hint: '●●●●●●●●●',
                  controller: controller.currentPasswordController,
                  isPassword: controller.obscureCurrent.value,
                  suffixIcon: IconButton(
                    icon: Icon(controller.obscureCurrent.value ? Icons.visibility_off : Icons.visibility, color: AppColors.greyText, size: 20),
                    onPressed: () => controller.obscureCurrent.toggle(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Current password is required' : null,
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => CustomTextField(
                  label: 'New Password',
                  hint: '●●●●●●●●●',
                  controller: controller.newPasswordController,
                  isPassword: controller.obscureNew.value,
                  suffixIcon: IconButton(
                    icon: Icon(controller.obscureNew.value ? Icons.visibility_off : Icons.visibility, color: AppColors.greyText, size: 20),
                    onPressed: () => controller.obscureNew.toggle(),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => CustomTextField(
                  label: 'Confirm New Password',
                  hint: '●●●●●●●●●',
                  controller: controller.confirmPasswordController,
                  isPassword: controller.obscureConfirm.value,
                  suffixIcon: IconButton(
                    icon: Icon(controller.obscureConfirm.value ? Icons.visibility_off : Icons.visibility, color: AppColors.greyText, size: 20),
                    onPressed: () => controller.obscureConfirm.toggle(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your new password';
                    if (v != controller.newPasswordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: controller.isLoading.value ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)) : Text('Update Password', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
