import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/style_resource.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/gradient_button.dart';
import 'sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: "Sign up",
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Join the network', style: StyleResource.instance.styleBold(fontSize: 28, color: AppColors.black)),
            const SizedBox(height: AppSpacing.sm),
            Text('Set up your business profile to start managing\ninvoices with precision and speed.', style: StyleResource.instance.styleRegular(fontSize: 15, color: AppColors.greyText)),
            const SizedBox(height: AppSpacing.lg),
            Form(
              key: controller.formKey,
              child: Column(
                children: [
                  _buildSectionCard(
                    title: 'GENERAL INFORMATION',
                    children: [
                      CustomTextField(label: 'Full Name', hint: 'e.g. Acme Corp', controller: controller.fullNameController, validator: (v) => controller.validateRequired(v, 'Full Name')),
                      const SizedBox(height: AppSpacing.md),
                      CustomTextField(label: 'Business Name', hint: 'e.g. Acme Corp', controller: controller.businessNameController, validator: (v) => controller.validateRequired(v, 'Business Name')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionCard(
                    title: 'CONTACT DETAILS',
                    children: [
                      CustomTextField(
                        label: 'Mobile',
                        hint: '+1 (555) 000-0000',
                        keyboardType: TextInputType.phone,
                        controller: controller.mobileController,
                        validator: controller.validateMobile,
                        suffixIcon: const Icon(Icons.phone_iphone, color: AppColors.borderGrey),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CustomTextField(
                        label: 'Email',
                        hint: 'name@company.com',
                        keyboardType: TextInputType.emailAddress,
                        controller: controller.emailController,
                        validator: controller.validateEmail,
                        suffixIcon: const Icon(Icons.alternate_email, color: AppColors.borderGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionCard(
                    title: 'SECURITY',
                    children: [
                      Obx(
                        () => CustomTextField(
                          label: 'Password',
                          hint: '●●●●●●●●●',
                          controller: controller.passwordController,
                          isPassword: !controller.isPasswordVisible.value,
                          validator: controller.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(controller.isPasswordVisible.value ? Icons.lock_open : Icons.lock_outline, color: AppColors.borderGrey),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Obx(
                        () => CustomTextField(
                          label: 'Confirm',
                          hint: '●●●●●●●●●',
                          controller: controller.confirmPasswordController,
                          isPassword: !controller.isConfirmPasswordVisible.value,
                          validator: controller.validateConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(controller.isConfirmPasswordVisible.value ? Icons.verified_user : Icons.verified_outlined, color: AppColors.borderGrey),
                            onPressed: controller.toggleConfirmPasswordVisibility,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: false, // For UI purpose, it can be bound to controller
                          onChanged: (val) {},
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(color: AppColors.borderGrey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.black).copyWith(decoration: TextDecoration.underline),
                              ),
                              const TextSpan(text: ' and\n'),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.black).copyWith(decoration: TextDecoration.underline),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Obx(() => GradientButton(text: 'Create Account →', isLoading: controller.isLoading.value, onPressed: controller.signUp)),
                  const SizedBox(height: AppSpacing.xxl),

                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1555421689-d68471e189f2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: StyleResource.instance.styleMedium(color: AppColors.greyText)),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Text("Log in here", style: StyleResource.instance.styleBold(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.primary, letterSpacing: 1.5)),
        const SizedBox(height: AppSpacing.lg),
        ...children,
      ],
    );
  }
}
