import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/style_resource.dart';
import '../../../../core/utils/assets_res.dart';
import '../../../../routes/app_pages.dart';
import '../../../widgets/base_view.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/gradient_button.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Image.asset(AssetsRes.logo, height: 80),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF3E8E0), borderRadius: BorderRadius.circular(20)),
                child: Text('PREMIUM ACCESS', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: const Color(0xFFB05615))),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Welcome Back', style: StyleResource.instance.styleBold(fontSize: 28, color: AppColors.black)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Seamlessly manage your professional\nbilling ecosystem.',
                textAlign: TextAlign.center,
                style: StyleResource.instance.styleRegular(fontSize: 15, color: AppColors.greyText),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(label: 'Email Address', hint: 'name@company.com', controller: controller.emailController, keyboardType: TextInputType.emailAddress, validator: controller.validateEmail),
                    const SizedBox(height: AppSpacing.lg),
                    Obx(
                      () => CustomTextField(
                        label: 'Password',
                        hint: "●●●●●●●●●",
                        controller: controller.passwordController,
                        isPassword: !controller.isPasswordVisible.value,
                        validator: controller.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off, color: AppColors.greyText),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text('Forgot Password?', style: StyleResource.instance.styleSemiBold(color: const Color(0xFFB05615))),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Obx(() => GradientButton(text: 'SIGN IN', isLoading: controller.isLoading.value, onPressed: controller.login)),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("New to Invoxa? ", style: StyleResource.instance.styleMedium(color: AppColors.greyText))],
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.SIGN_UP);
                        },
                        child: Text(
                          "Create a professional account",
                          style: StyleResource.instance.styleSemiBold(color: AppColors.black).copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Center(
                      child: Text('© 2024 Invoxa. Precision Billing & Magic UX.', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
