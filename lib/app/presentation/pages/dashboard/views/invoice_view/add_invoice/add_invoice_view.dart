import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../../data/models/customer_model.dart';
import '../../../../../../data/models/invoice_model.dart';
import '../../../../../../routes/app_pages.dart';
import 'add_invoice_controller.dart';

class AddInvoiceView extends GetView<AddInvoiceController> {
  const AddInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Create Invoice',
      bottomNavigationBar: _buildMagicFooter(),
      child: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildMagicHeader(),
                  const SizedBox(height: 24),
                  _buildCombinedSellerBankCard(),
                  const SizedBox(height: 24),
                  _buildBuyerSection(),
                  const SizedBox(height: 32),
                  _buildItemsSection(),
                  const SizedBox(height: 32),
                  _buildTaxToggles(),
                  const SizedBox(height: 32),
                  _buildMagicTotalsSection(),
                  const SizedBox(height: 100),
                ],
              ),
      ),
    );
  }

  Widget _buildMagicHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice Number', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText).copyWith(letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(controller.invoiceNumber.value, style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Date', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText).copyWith(letterSpacing: 1)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _selectDate(Get.context!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                  child: Text(DateFormat('dd MMM').format(controller.invoiceDate.value), style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedSellerBankCard() {
    final seller = controller.sellerProfile.value;
    final bank = seller?.bankDetails;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.05), AppColors.white]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('FROM BUSINESS', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary).copyWith(letterSpacing: 1.5)),
                    const Icon(Icons.verified_user_rounded, color: Colors.green, size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                Text(seller?.businessName?.capitalize ?? 'Setting up...', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.secondary)),
                const SizedBox(height: 12),
                _buildModernInfoRow(Icons.location_on_rounded, '${seller?.address?.street}, ${seller?.address?.city}, ${seller?.address?.state} - ${seller?.address?.pincode}'),
                _buildModernInfoRow(Icons.description_rounded, 'GST: ${seller?.taxSettings?.gstNumber ?? 'N/A'}'),
                _buildModernInfoRow(Icons.phone_rounded, seller?.mobile ?? 'N/A'),
                _buildModernInfoRow(Icons.email_rounded, seller?.email ?? 'N/A'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.primaryBorder),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.account_balance_rounded, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bank?.bankName?.capitalize ?? 'Bank Not Set', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                      const SizedBox(height: 2),
                      Text('Holder: ${bank?.accountHolder?.capitalize ?? 'N/A'}', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary.withOpacity(0.8))),
                      Text('A/C: ${bank?.accountNumber ?? '****'}', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
                      Text('IFSC: ${bank?.ifsc ?? '****'} | Branch: ${bank?.branch ?? 'N/A'}', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BILL TO (BUYER)', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText).copyWith(letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CustomerModel>(
                      hint: Text('Select Customer', style: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.greyText)),
                      value: controller.selectedCustomer.value,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      items: controller.allCustomers
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name ?? '', style: StyleResource.instance.styleSemiBold(fontSize: 14)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => controller.selectCustomer(val!),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Get.toNamed(Routes.ADD_CUSTOMER);
                  if (result != null && result is CustomerModel) {
                    await controller.fetchInitialData(); // Refresh list
                    controller.selectCustomer(result); // Select the new one
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        if (controller.selectedCustomer.value != null) ...[const SizedBox(height: 16), _buildMagicCustomerPreview(controller.selectedCustomer.value!)],
      ],
    );
  }

  Widget _buildMagicCustomerPreview(CustomerModel customer) {
    final address = '${customer.address?.street ?? ''} ${customer.address?.city ?? ''} ${customer.address?.state ?? ''} ${customer.address?.zipCode ?? ''}'.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primarySoft.withOpacity(0.2), AppColors.white]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.contact_mail_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(customer.contactPerson?.capitalize ?? 'No Contact', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.primary)),
                ],
              ),
              IconButton(
                onPressed: () => Get.toNamed(Routes.ADD_CUSTOMER, arguments: {'customer': customer})?.then((_) => controller.fetchInitialData()),
                icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          Text(customer.name?.capitalize ?? '', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
          const SizedBox(height: 12),
          if (address.isNotEmpty) _buildModernInfoRow(Icons.location_on_rounded, address),
          if (customer.mobile != null && customer.mobile!.isNotEmpty) _buildModernInfoRow(Icons.phone_rounded, customer.mobile!),
          if (customer.email != null && customer.email!.isNotEmpty) _buildModernInfoRow(Icons.email_rounded, customer.email!),
          if (customer.gstNumber != null && customer.gstNumber!.isNotEmpty) _buildModernInfoRow(Icons.description_rounded, 'GST: ${customer.gstNumber}'),
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
            Text('ITEMS & SERVICES', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText).copyWith(letterSpacing: 1.5)),
            GestureDetector(
              onTap: () => _showMagicItemDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    Text('ADD ITEM', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.items.isEmpty)
          _buildEmptyItemsState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderGrey.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(item.name ?? '', style: StyleResource.instance.styleBold(fontSize: 15, color: AppColors.secondary)),
                        ),
                        IconButton(
                          onPressed: () => controller.removeItem(index),
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadge('Qty: ${item.quantity}', AppColors.secondary),
                        const SizedBox(width: 8),
                        _buildBadge('₹${item.rate}', AppColors.primary),
                        const Spacer(),
                        Text('₹${item.amount.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
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

  Widget _buildEmptyItemsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.5), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_rounded, size: 48, color: AppColors.greyText.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text('Ready to add your first item?', style: StyleResource.instance.styleMedium(color: AppColors.greyText)),
        ],
      ),
    );
  }

  Widget _buildTaxToggles() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TAX CONFIGURATION', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText).copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildModernToggle('CGST', controller.hasCGST), _buildModernToggle('SGST', controller.hasSGST), _buildModernToggle('IGST', controller.hasIGST)]),
        ],
      ),
    );
  }

  Widget _buildModernToggle(String label, RxBool state) {
    return GestureDetector(
      onTap: () => state.value = !state.value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: state.value ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: state.value ? AppColors.primary : AppColors.borderGrey),
        ),
        child: Text(label, style: StyleResource.instance.styleBold(fontSize: 13, color: state.value ? AppColors.white : AppColors.secondary)),
      ),
    );
  }

  Widget _buildMagicTotalsSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.secondary, Color(0xFF1A1F26)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15))],
      ),
      child: Column(
        children: [
          _buildSummaryLine('Sub Total', '₹${controller.subTotal.toStringAsFixed(2)}'),
          _buildSummaryLine('Discount', '-₹${controller.discountTotal.toStringAsFixed(2)}', valueColor: Colors.redAccent),
          _buildSummaryLine('GST (${controller.taxPercentage.value}%)', '₹${controller.taxTotal.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: StyleResource.instance.styleBold(fontSize: 20, color: Colors.white)),
              Text('₹${controller.grandTotal.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 28, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {Color valueColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: StyleResource.instance.styleMedium(fontSize: 15, color: Colors.white60)),
          Text(value, style: StyleResource.instance.styleBold(fontSize: 16, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildMagicFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('DRAFT', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => controller.saveInvoice(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: AppColors.primary.withOpacity(0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SAVE INVOICE', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                  const SizedBox(width: 12),
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  Widget _buildModernInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: StyleResource.instance.styleMedium(fontSize: 13, color: AppColors.secondary.withOpacity(0.7))),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: StyleResource.instance.styleBold(fontSize: 11, color: color)),
    );
  }

  void _showMagicItemDialog() {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final discountCtrl = TextEditingController(text: '0');
    final hsnCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: AppColors.borderGrey, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Text('ADD PRODUCT', style: StyleResource.instance.styleBold(fontSize: 24, color: AppColors.secondary)),
              const SizedBox(height: 24),
              _buildMagicInput('Product Name', nameCtrl, Icons.shopping_bag_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMagicInput('Rate', rateCtrl, Icons.payments_outlined, type: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMagicInput('Qty', qtyCtrl, Icons.add_box_outlined, type: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMagicInput('Disc %', discountCtrl, Icons.percent_rounded, type: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMagicInput('HSN Code', hsnCtrl, Icons.qr_code_rounded)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || rateCtrl.text.isEmpty) return;
                    final rate = double.tryParse(rateCtrl.text) ?? 0.0;
                    final qty = double.tryParse(qtyCtrl.text) ?? 1.0;
                    final disc = double.tryParse(discountCtrl.text) ?? 0.0;
                    final amount = (rate * qty) - (rate * qty * (disc / 100));

                    controller.addItem(InvoiceItem(name: nameCtrl.text, rate: rate, quantity: qty, discount: disc, hsnCode: hsnCtrl.text, amount: amount, unit: 'PCS'));
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('ADD TO LIST', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMagicInput(String label, TextEditingController ctrl, IconData icon, {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: StyleResource.instance.styleSemiBold(fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.primarySoft.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: controller.invoiceDate.value, firstDate: DateTime(2020), lastDate: DateTime(2101));
    if (picked != null) controller.invoiceDate.value = picked;
  }
}
