import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../widgets/custom_text_field.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Settings',
      child: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionHeader(Icons.description_outlined, 'Invoice Settings'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Currency Selection'),
                          _buildDropdown(controller.currency, ['INR - Indian Rupee', 'USD - US Dollar', 'EUR - Euro']),
                          const SizedBox(height: 20),
                          CustomTextField(label: 'Invoice Prefix', hint: 'INV-', controller: controller.prefixController),
                          const SizedBox(height: 20),
                          _buildLabel('Financial Year Format'),
                          _buildDropdown(controller.financialYear, ['Apr - Mar', 'Jan - Dec'], icon: Icons.calendar_today_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.account_balance_wallet_outlined, 'Tax Settings'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildToggleRow('Enable GST', 'Apply Goods & Services Tax', controller.enableGST),
                          if (controller.enableGST.value) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Text('${controller.gstRate.value.toInt()}%', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary))],
                            ),
                            Slider(value: controller.gstRate.value, min: 0, max: 28, divisions: 28, activeColor: AppColors.primary, onChanged: (val) => controller.gstRate.value = val),
                          ],
                          const Divider(height: 32),
                          _buildToggleRow('Enable VAT', 'Apply Value Added Tax', controller.enableVAT),
                          if (controller.enableVAT.value) ...[const SizedBox(height: 20), CustomTextField(label: 'DEFAULT VAT PERCENTAGE', hint: '5', controller: controller.vatRateController, keyboardType: TextInputType.number)],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.save_outlined, color: AppColors.white),
                        label: Text('Save Preferences', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(title, style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),

      child: child,
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.black)),
    );
  }

  Widget _buildDropdown(RxString value, List<String> items, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.value,
          isExpanded: true,
          icon: Icon(icon ?? Icons.keyboard_arrow_down, color: AppColors.primary),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: StyleResource.instance.styleRegular(color: AppColors.black, fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => value.value = val!,
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, RxBool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
            Text(subtitle, style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
          ],
        ),
        Switch(value: value.value, onChanged: (val) => value.value = val, activeColor: AppColors.primary),
      ],
    );
  }
}

Widget _buildToggleRow(String title, String subtitle, RxBool value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
          Text(subtitle, style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
        ],
      ),
      Switch(value: value.value, onChanged: (val) => value.value = val, activeColor: AppColors.primary),
    ],
  );
}
