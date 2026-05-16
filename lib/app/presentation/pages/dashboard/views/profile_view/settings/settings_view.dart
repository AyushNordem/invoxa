import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../../../../core/theme/style_resource.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text('Settings', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.primary)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex')),
          )
        ],
      ),
      body: Obx(() => controller.isLoading.value
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
                        const Divider(height: 32),
                        _buildLabel('Invoice Prefix'),
                        _buildTextField(controller: controller.prefixController, hint: 'INV-', suffixIcon: Icons.tag),
                        const Divider(height: 32),
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
                        _buildToggleRow(
                          'Enable GST',
                          'Apply Goods & Services Tax',
                          controller.enableGST,
                        ),
                        if (controller.enableGST.value) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${controller.gstRate.value.toInt()}%', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary)),
                            ],
                          ),
                          Slider(
                            value: controller.gstRate.value,
                            min: 0,
                            max: 28,
                            divisions: 28,
                            activeColor: AppColors.primary,
                            onChanged: (val) => controller.gstRate.value = val,
                          ),
                        ],
                        const Divider(height: 32),
                        _buildToggleRow(
                          'Enable VAT',
                          'Apply Value Added Tax',
                          controller.enableVAT,
                        ),
                        if (controller.enableVAT.value) ...[
                          const SizedBox(height: 16),
                          _buildLabel('DEFAULT VAT PERCENTAGE'),
                          _buildTextField(controller: controller.vatRateController, hint: '5', suffixText: '%'),
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
            )),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.greyText.withOpacity(0.7))),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, IconData? suffixIcon, String? suffixText}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        style: StyleResource.instance.styleSemiBold(fontSize: 16, color: AppColors.secondary),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: AppColors.borderGrey) : null,
          suffixText: suffixText,
          suffixStyle: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.borderGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown(RxString value, List<String> items, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.value,
          isExpanded: true,
          icon: Icon(icon ?? Icons.keyboard_arrow_down, color: AppColors.borderGrey),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: StyleResource.instance.styleSemiBold(fontSize: 16, color: AppColors.secondary)),
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
        Switch(
          value: value.value,
          onChanged: (val) => value.value = val,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
