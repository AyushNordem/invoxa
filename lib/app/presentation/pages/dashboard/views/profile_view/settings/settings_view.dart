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
                          _buildDropdown(controller.currency, ['₹ INR - Indian Rupee', '\$ USD - US Dollar', '€ EUR - Euro']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.straighten_outlined, 'Units of Measurement'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.units
                                .map(
                                  (unit) => Chip(
                                    label: Text(unit, style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.secondary)),
                                    backgroundColor: AppColors.primarySoft,
                                    deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
                                    onDeleted: () => controller.removeUnit(unit),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller.customUnitController,
                                  decoration: InputDecoration(
                                    hintText: 'Add custom unit (e.g. Box)',
                                    hintStyle: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText),
                                    filled: true,
                                    fillColor: AppColors.borderGrey.withOpacity(0.1),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: controller.addCustomUnit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.all(12),
                                ),
                                child: const Icon(Icons.add, color: AppColors.white),
                              ),
                            ],
                          ),
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
                            const SizedBox(height: 20),
                            CustomTextField(label: 'CGST (Central Tax) %', hint: '9', controller: controller.cgstController, keyboardType: TextInputType.number),
                            const SizedBox(height: 16),
                            CustomTextField(label: 'SGST (State Tax) %', hint: '9', controller: controller.sgstController, keyboardType: TextInputType.number),
                            const SizedBox(height: 16),
                            CustomTextField(label: 'IGST (Integrated Tax) %', hint: '18', controller: controller.igstController, keyboardType: TextInputType.number),
                          ],
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

  Widget _buildSubToggleRow(String title, RxBool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.secondary)),
          Transform.scale(
            scale: 0.8,
            child: Switch(value: value.value, onChanged: (val) => value.value = val, activeColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
