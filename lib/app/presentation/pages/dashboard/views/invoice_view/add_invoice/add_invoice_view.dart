import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:invoxa/app/presentation/widgets/custom_text_field.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../../core/utils/app_snackbar.dart';
import '../../../../../../data/models/customer_model.dart';
import '../../../../../../data/models/invoice_model.dart';
import '../../../../../../routes/app_pages.dart';
import 'add_invoice_controller.dart';

class AddInvoiceView extends GetView<AddInvoiceController> {
  const AddInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('New Invoice', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.primary)),
        centerTitle: false,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeaderSection(),
                    const SizedBox(height: 24),
                    _buildSellerCard(),
                    const SizedBox(height: 24),
                    _buildBankDetailsCard(),
                    const SizedBox(height: 24),
                    _buildBuyerSection(),
                    const SizedBox(height: 24),
                    _buildItemsSection(),
                    const SizedBox(height: 24),
                    _buildTaxToggles(),
                    const SizedBox(height: 24),
                    _buildTotalsSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputLabel('Invoice Number', controller.invoiceNumberController, isEnabled: false)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice Date', style: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.black)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(Get.context!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.borderGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primarySoft),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd MMM yyyy').format(controller.invoiceDate.value), style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary)),
                            const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard() {
    final seller = controller.sellerProfile.value;
    return _buildExpandableCard(
      title: 'SELLER DETAILS (FROM PROFILE)',
      icon: Icons.business_center_outlined,
      child: seller == null
          ? Text('No business profile found. Please set up in profile.', style: StyleResource.instance.styleMedium(color: Colors.red))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seller.businessName ?? 'N/A', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
                const SizedBox(height: 8),
                _buildInfoLine(Icons.location_on_outlined, '${seller.address?.street}, ${seller.address?.city}, ${seller.address?.state}'),
                _buildInfoLine(Icons.email_outlined, seller.email ?? 'N/A'),
                _buildInfoLine(Icons.phone_outlined, seller.mobile ?? 'N/A'),
                _buildInfoLine(Icons.description_outlined, 'GST: ${seller.taxSettings?.gstNumber ?? 'N/A'}'),
              ],
            ),
    );
  }

  Widget _buildBankDetailsCard() {
    final bank = controller.sellerProfile.value?.bankDetails;
    return _buildExpandableCard(
      title: 'BANK DETAILS',
      icon: Icons.account_balance_outlined,
      child: bank == null
          ? Text('No bank details found.', style: StyleResource.instance.styleMedium(color: AppColors.greyText))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.bankName ?? 'N/A', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                const SizedBox(height: 4),
                Text('A/C: ${bank.accountNumber ?? 'N/A'}', style: StyleResource.instance.styleMedium(fontSize: 13, color: AppColors.secondary)),
                Text('IFSC: ${bank.ifsc ?? 'N/A'}', style: StyleResource.instance.styleMedium(fontSize: 13, color: AppColors.secondary)),
              ],
            ),
    );
  }

  Widget _buildBuyerSection() {
    return _buildExpandableCard(
      title: 'BILL TO (BUYER)',
      icon: Icons.person_pin_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CustomerModel>(
                      hint: Text('Select Existing Customer', style: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.greyText)),
                      value: controller.selectedCustomer.value,
                      isExpanded: true,
                      items: controller.allCustomers.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.name ?? '', style: StyleResource.instance.styleSemiBold(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) => controller.selectCustomer(val!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => Get.toNamed(Routes.ADD_CUSTOMER),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                tooltip: 'Add New Customer',
              ),
            ],
          ),
          if (controller.selectedCustomer.value != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primarySoft.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(controller.selectedCustomer.value!.name ?? '', style: StyleResource.instance.styleBold(fontSize: 15)),
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${controller.selectedCustomer.value!.address?.street}, ${controller.selectedCustomer.value!.address?.city}', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
                  Text('GST: ${controller.selectedCustomer.value!.gstNumber ?? 'N/A'}', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ITEMS & SERVICES', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary).copyWith(letterSpacing: 1)),
            TextButton.icon(
              onPressed: () => _showAddItemDialog(),
              icon: const Icon(Icons.add_box_outlined, size: 18),
              label: Text('Add Item', style: StyleResource.instance.styleBold(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (controller.items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGrey.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.greyText.withOpacity(0.2)),
                const SizedBox(height: 12),
                Text('No items added yet', style: StyleResource.instance.styleMedium(color: AppColors.greyText)),
              ],
            ),
          )
        else
          ListView.builder(
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGrey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name ?? 'Item', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                        IconButton(
                          onPressed: () => controller.removeItem(index),
                          icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                        ),
                      ],
                    ),
                    if (item.hsnCode != null) Text('HSN: ${item.hsnCode}', style: StyleResource.instance.styleMedium(fontSize: 11, color: AppColors.greyText)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity} ${item.unit} x ₹${item.rate}', style: StyleResource.instance.styleMedium(fontSize: 13, color: AppColors.secondary)),
                        Text('₹${item.amount.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTaxToggles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TAX SETTINGS', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText)),
          const SizedBox(height: 12),
          Row(children: [_buildTaxChip('CGST', controller.hasCGST), const SizedBox(width: 8), _buildTaxChip('SGST', controller.hasSGST), const SizedBox(width: 8), _buildTaxChip('IGST', controller.hasIGST)]),
        ],
      ),
    );
  }

  Widget _buildTaxChip(String label, RxBool state) {
    return ChoiceChip(
      label: Text(label, style: StyleResource.instance.styleBold(fontSize: 12, color: state.value ? AppColors.white : AppColors.secondary)),
      selected: state.value,
      onSelected: (val) => state.value = val,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.borderGrey.withOpacity(0.2),
    );
  }

  Widget _buildTotalsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _buildSummaryRow('Sub Total', '₹${controller.subTotal.toStringAsFixed(2)}', Colors.white70),
          _buildSummaryRow('Discount', '-₹${controller.discountTotal.toStringAsFixed(2)}', Colors.redAccent.withOpacity(0.8)),
          _buildSummaryRow('GST (${controller.taxPercentage.value}%)', '₹${controller.taxTotal.toStringAsFixed(2)}', Colors.white70),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: StyleResource.instance.styleBold(fontSize: 18, color: Colors.white)),
              Text('₹${controller.grandTotal.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 22, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: StyleResource.instance.styleMedium(fontSize: 14, color: color)),
          Text(value, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.saveInvoice(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text('Generate & Save Invoice', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
      ),
    );
  }

  // Helper Widgets
  Widget _buildExpandableCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: StyleResource.instance.styleBold(fontSize: 11, color: AppColors.greyText).copyWith(letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.greyText.withOpacity(0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: StyleResource.instance.styleMedium(fontSize: 13, color: AppColors.secondary.withOpacity(0.8))),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, TextEditingController ctrl, {bool isEnabled = true}) {
    return CustomTextField(label: label, hint: "Enter Invoice Number", controller: ctrl);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: controller.invoiceDate.value, firstDate: DateTime(2020), lastDate: DateTime(2101));
    if (picked != null) controller.invoiceDate.value = picked;
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final discountCtrl = TextEditingController(text: '0');
    final hsnCtrl = TextEditingController();
    final unit = 'PCS'.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Product/Service', style: StyleResource.instance.styleBold(fontSize: 20)),
              const SizedBox(height: 20),
              _buildDialogField('Item Name*', nameCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDialogField('Rate/Price*', rateCtrl, type: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogField('Quantity*', qtyCtrl, type: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDialogField('Discount %', discountCtrl, type: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogField('HSN/SAC', hsnCtrl)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || rateCtrl.text.isEmpty) {
                      AppSnackbar.showError(title: 'Error', message: 'Please fill required fields');
                      return;
                    }
                    final rate = double.tryParse(rateCtrl.text) ?? 0.0;
                    final qty = double.tryParse(qtyCtrl.text) ?? 1.0;
                    final disc = double.tryParse(discountCtrl.text) ?? 0.0;
                    final amount = (rate * qty) - (rate * qty * (disc / 100));

                    controller.addItem(InvoiceItem(name: nameCtrl.text, rate: rate, quantity: qty, discount: disc, hsnCode: hsnCtrl.text, amount: amount, unit: 'PCS'));
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add to Invoice', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController ctrl, {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.borderGrey.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
