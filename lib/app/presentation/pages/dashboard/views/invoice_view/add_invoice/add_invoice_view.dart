import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../../routes/app_pages.dart';
import 'add_invoice_controller.dart';

class AddInvoiceView extends GetView<AddInvoiceController> {
  const AddInvoiceView({super.key});

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
        title: Text('Create Invoice', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.primary)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex')),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.description_outlined,
              title: 'INVOICE DETAILS',
              child: Column(
                children: [
                  _buildLabel('Invoice Number'),
                  _buildTextField(controller: controller.invoiceNumberController, hint: 'INV-2024-001'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Invoice Date'),
                            _buildTextField(controller: controller.invoiceDateController, hint: 'mm/dd/yyyy', suffixIcon: Icons.calendar_today_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Due Date'),
                            _buildTextField(controller: controller.dueDateController, hint: 'mm/dd/yyyy', suffixIcon: Icons.calendar_today_outlined),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Payment Method'),
                  _buildDropdown(),
                  const SizedBox(height: 16),
                  _buildLabel('Place of Supply'),
                  _buildTextField(hint: 'Search state...', suffixIcon: Icons.search),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.group_outlined,
              title: 'CUSTOMER INFORMATION',
              child: Column(
                children: [
                  _buildSegmentedControl(),
                  const SizedBox(height: 16),
                  _buildCustomerCard(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('ITEMS & SERVICES', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary.withOpacity(0.6))),
                  ],
                ),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                      child: Text('${controller.items.length} Items', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary)),
                    )),
              ],
            ),
            const SizedBox(height: 12),
            _buildItemsList(),
            const SizedBox(height: 16),
            _buildAddItemButton(),
            const SizedBox(height: 24),
            _buildTotals(),
            const SizedBox(height: 32),
            _buildFooterButtons(),
            const SizedBox(height: 40),
          ],
        ),
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

  Widget _buildTextField({TextEditingController? controller, required String hint, IconData? suffixIcon}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText.withOpacity(0.5)),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.greyText.withOpacity(0.5), size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.paymentMethod.value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.greyText.withOpacity(0.5)),
              items: ['Bank Transfer', 'Cash', 'Credit Card'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary)),
                );
              }).toList(),
              onChanged: (val) => controller.paymentMethod.value = val!,
            ),
          )),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Obx(() => Row(
            children: [
              _buildSegmentItem('Existing', controller.isExistingCustomer.value),
              _buildSegmentItem('New Customer', !controller.isExistingCustomer.value),
            ],
          )),
    );
  }

  Widget _buildSegmentItem(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (label == 'New Customer') {
            Get.toNamed(Routes.ADD_CUSTOMER);
          } else {
            controller.isExistingCustomer.value = true;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isActive ? [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 4)] : null,
          ),
          child: Center(
            child: Text(label, style: StyleResource.instance.styleBold(fontSize: 14, color: isActive ? AppColors.primary : AppColors.greyText)),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.business, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Acme Corp Solutions', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
                    Text('contact@acme.com', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.greyText, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('123 Tech Park, Block 4, Mumbai, MH', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.card,
                border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['title'], style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                      const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    ],
                  ),
                  Text(item['description'], style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Qty / Unit', style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText)),
                          Text(item['qty'], style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Price', style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText)),
                          Text('\$${(item['price'] as double).toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget _buildAddItemButton() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.ADD_PRODUCT),
      child: Container(
        width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), style: BorderStyle.solid),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text('Add Product or Service', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary)),
        ],
      ),
    ));
  }

  Widget _buildTotals() {
    return Obx(() => Column(
          children: [
            _buildTotalRow('Subtotal', '\$${controller.subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildTotalRow('Tax (GST 18%)', '\$${controller.tax.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildTotalRow('Grand Total', '\$${controller.total.toStringAsFixed(2)}', isBold: true),
          ],
        ));
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isBold ? StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary) : StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.greyText)),
        Text(value, style: isBold ? StyleResource.instance.styleBold(fontSize: 16, color: AppColors.primary) : StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderGrey),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save Draft', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Generate Invoice', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
          ),
        ),
      ],
    );
  }
}
