import 'dart:io';

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
      title: 'Edit Profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildImagePicker(),
            const SizedBox(height: 40),
            CustomTextField(label: 'Full Name', hint: 'Enter your name', controller: controller.fullNameController, prefixIcon: Icons.person_outline),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email Address',
              hint: 'email@example.com',
              controller: controller.emailController,
              prefixIcon: Icons.email_outlined,
              // Email is usually not editable easily
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)) : Text('Save Changes', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          Obx(() {
            final path = controller.profileImagePath.value;
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primarySoft, width: 4),
                image: DecorationImage(image: path.isEmpty ? const NetworkImage('https://i.pravatar.cc/150?u=alex') as ImageProvider : (path.startsWith('http') ? NetworkImage(path) : FileImage(File(path))) as ImageProvider, fit: BoxFit.cover),
              ),
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: AppColors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
