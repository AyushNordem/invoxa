import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/style_resource.dart';
import '../../../widgets/custom_text_field.dart';
import 'business_setup_controller.dart';

class BusinessSetupView extends GetView<BusinessSetupController> {
  const BusinessSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Business Setup',
      showBackButton: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: controller.formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Business Profile', style: StyleResource.instance.styleBold(fontSize: 28, color: AppColors.black)),
              const SizedBox(height: AppSpacing.sm),
              Text('Finalize your professional identity and banking details for seamless invoicing.', style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText)),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionCard(
                icon: Icons.business,
                title: 'Business Information',
                children: [
                  _buildUploadBox(label: 'Upload Business Logo', subtext: 'SVG, PNG or JPG (max. 2MB)', isLogo: true),
                  const SizedBox(height: AppSpacing.md),

                  CustomTextField(label: 'Business Name', hint: 'e.g. Acme Corp', controller: controller.businessNameController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Owner Name', hint: 'John Doe', controller: controller.ownerNameController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'GST Number', hint: '22AAAAA0000A1Z5', controller: controller.gstController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Tax Number (PAN/EIN)', hint: 'ABCDE1234F', controller: controller.taxNumberController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Business Email', hint: 'contact@business.com', controller: controller.emailController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Phone Number', hint: '+1 (555) 000-0000', controller: controller.mobileController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Business Address', hint: 'Street, Building, Suite...', controller: controller.addressController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'State / Province', hint: 'Select State', controller: controller.cityController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Pincode / Zip', hint: '000000', controller: controller.pincodeController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Website (Optional)', hint: 'www.yourbusiness.com', controller: controller.websiteController),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionCard(
                icon: Icons.account_balance,
                title: 'Banking Information',
                children: [
                  CustomTextField(label: 'Account Holder Name', hint: 'Full name as per bank records', controller: controller.accountHolderController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Bank Name', hint: 'Global Trust Bank', controller: controller.bankNameController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Branch Name', hint: 'Downtown Branch', controller: controller.branchController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'Account Number', hint: '**** **** **** 1234', controller: controller.accountNumberController),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(label: 'IFSC / SWIFT Code', hint: 'CTB0001234', controller: controller.ifscController),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              _buildSectionCard(
                icon: Icons.edit,
                title: 'Digital Signature',
                children: [_buildUploadBox(label: 'Click to upload or draw signature', subtext: 'Upload File | Draw Now', isLogo: false, isSignature: true)],
              ),
              const SizedBox(height: AppSpacing.xxl),

              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Save & Complete Setup', style: StyleResource.instance.styleSemiBold(fontSize: 16, color: AppColors.white)),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_outline, color: AppColors.white, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title, style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.black)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...children,
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildUploadBox({required String label, required String subtext, required bool isLogo, bool isSignature = false}) {
    return Obx(() {
      String path = isLogo ? controller.logoPath.value : controller.signaturePath.value;
      return GestureDetector(
        onTap: () => controller.pickImage(isLogo),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.none),
          ),
          child: CustomPaint(
            painter: DashedBorderPainter(color: AppColors.primary.withOpacity(0.5)),
            child: path.isEmpty
                ? Column(
                    children: [
                      const SizedBox(height: 16),
                      if (isSignature)
                        const Icon(Icons.edit, color: AppColors.greyText, size: 24)
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isSignature) const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 16),
                          if (!isSignature) const SizedBox(width: 4),
                          Text(label, style: StyleResource.instance.styleSemiBold(fontSize: 12, color: isSignature ? AppColors.greyText : AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (isSignature)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 14),
                            const SizedBox(width: 4),
                            Text('Upload File', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.primary)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('|', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.borderGrey)),
                            ),
                            const Icon(Icons.edit, color: AppColors.greyText, size: 14),
                            const SizedBox(width: 4),
                            Text('Draw Now', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText)),
                          ],
                        )
                      else
                        Text(subtext, style: StyleResource.instance.styleMedium(fontSize: 10, color: AppColors.greyText)),
                      const SizedBox(height: 16),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(path), height: 100, fit: BoxFit.contain),
                  ),
          ),
        ),
      );
    });
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
