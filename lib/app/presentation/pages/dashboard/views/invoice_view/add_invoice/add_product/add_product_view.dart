import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_sizes.dart';
import '../../../../../../../core/theme/style_resource.dart';
import 'add_product_controller.dart';

class AddProductView extends GetView<AddProductController> {
  const AddProductView({super.key});

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
        title: Text('Add New Product', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.secondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.info_outline,
              title: 'GENERAL INFORMATION',
              child: Column(
                children: [
                  _buildLabel('Product / Service Name'),
                  _buildTextField(controller: controller.productNameController, hint: 'e.g. Cloud Hosting Pro'),
                  const SizedBox(height: 16),
                  _buildLabel('Description'),
                  _buildTextField(controller: controller.descriptionController, hint: 'Provide details about the service...', maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Category'),
                            _buildDropdown(controller: controller.category, items: ['Software', 'Hardware', 'Service']),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('HSN / SAC Code'),
                            _buildTextField(controller: controller.hsnController, hint: '998311'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.payments_outlined,
              title: 'PRICING & TAX',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Unit Price'),
                            _buildTextField(controller: controller.priceController, hint: '\$ 0.00'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Unit'),
                            _buildDropdown(controller: controller.unit, items: ['Pcs', 'Hrs', 'Box']),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tax Rate (GST)'),
                            _buildDropdown(controller: controller.taxRate, items: ['18%', '12%', '5%', '0%']),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Discount'),
                            _buildTextField(controller: controller.discountController, hint: '0', suffixText: '%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInventoryToggle(),
            const SizedBox(height: 16),
            _buildAddImageButton(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save_outlined, color: AppColors.white),
                label: Text('Save Product', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Details', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
                const SizedBox(height: 4),
                Text('Set up your catalog items for faster invoicing and inventory tracking.', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadius.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.greyText)),
    );
  }

  Widget _buildTextField({TextEditingController? controller, required String hint, int maxLines = 1, String? suffixText}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText.withOpacity(0.5)),
          suffixText: suffixText,
          suffixStyle: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.greyText.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown({required RxString controller, required List<String> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.greyText.withOpacity(0.5)),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary)),
              );
            }).toList(),
            onChanged: (val) => controller.value = val!,
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadius.card),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TRACK INVENTORY', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary.withOpacity(0.6))),
              Text('Manage stock levels', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
            ],
          ),
          Obx(() => Switch(value: controller.isTrackingInventory.value, onChanged: (val) => controller.isTrackingInventory.value = val, activeColor: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.5), style: BorderStyle.none),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(color: AppColors.borderGrey.withOpacity(0.5)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Text('Add Image', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary)),
                ],
              ),
              const Icon(Icons.chevron_right, color: AppColors.greyText),
            ],
          ),
        ),
      ),
    );
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
