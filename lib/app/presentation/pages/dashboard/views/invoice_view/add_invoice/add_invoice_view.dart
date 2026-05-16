import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:invoxa/app/core/theme/app_sizes.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';
import 'package:invoxa/app/presentation/widgets/gradient_button.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../../core/utils/app_snackbar.dart' show AppSnackbar;
import '../../../../../../data/models/customer_model.dart';
import '../../../../../../data/models/invoice_model.dart';
import '../../../../../../routes/app_pages.dart';
import 'add_invoice_controller.dart';
import 'invoice_pdf_view.dart';

class AddInvoiceView extends GetView<AddInvoiceController> {
  const AddInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Create Invoice',
      bottomNavigationBar: Obx(() => GradientButton(text: "Save Invoice", isLoading: controller.isButtonLoading.value, onPressed: () => controller.saveInvoice()).paddingSymmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm)),
      child: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildMagicHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCombinedSellerBankCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildBuyerSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildItemsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTaxToggles(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMagicTotalsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInvoicePreviewSection(),
                  const SizedBox(height: 50),
                ],
              ),
      ),
    );
  }

  Widget _buildInvoicePreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('INVOICE PREVIEW', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText).copyWith(letterSpacing: 1.5)),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.fullscreen_rounded, size: 18),
              label: Text('FULL SCREEN', style: StyleResource.instance.styleBold(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Visibility(
            visible: controller.items.isNotEmpty && controller.selectedCustomer.value != null,
            child: SizedBox(
              height: 500,
              width: double.infinity,
              child: PdfPreview(
                build: (format) => InvoicePdfGenerator.generate(controller.createInvoice.value),
                allowPrinting: true, // shows print button
                allowSharing: true, // shows share button
                canChangePageFormat: false,
                canChangeOrientation: false,
                initialPageFormat: PdfPageFormat.a4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceLayout() {
    final seller = controller.sellerProfile.value;
    final buyer = controller.selectedCustomer.value;
    final items = controller.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text('Tax Invoice', style: StyleResource.instance.styleBold(fontSize: 22, color: Colors.black)),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
          child: Column(
            children: [
              // Header Table
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(seller?.businessName?.toUpperCase() ?? 'YOUR BUSINESS NAME', style: StyleResource.instance.styleBold(fontSize: 14)),
                          Text('${seller?.address?.street}, ${seller?.address?.city}\n${seller?.address?.state}, ${seller?.address?.pincode}', style: const TextStyle(fontSize: 10)),
                          Text('GSTIN/UIN: ${seller?.gstNumber ?? 'N/A'}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('Contact: ${seller?.mobile ?? 'N/A'} | Email: ${seller?.email ?? 'N/A'}', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [_buildPreviewKeyValue('Invoice No.', controller.invoiceNumber.value), _buildPreviewKeyValue('Dated', DateFormat('dd-MMM-yy').format(controller.invoiceDate.value)), _buildPreviewKeyValue('Delivery Note', '-'), _buildPreviewKeyValue('Terms of Payment', 'Immediate')],
                    ),
                  ),
                ],
              ),
              // Buyer/Consignee Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Buyer (Bill to)',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                          ),
                          Text(buyer?.name?.toUpperCase() ?? 'SELECT CUSTOMER', style: StyleResource.instance.styleBold(fontSize: 12)),
                          Text('${buyer?.address?.street}, ${buyer?.address?.city}\n${buyer?.address?.state}, ${buyer?.address?.zipCode}', style: const TextStyle(fontSize: 10)),
                          Text('GSTIN/UIN: ${buyer?.gstNumber ?? 'N/A'}', style: const TextStyle(fontSize: 10)),
                          Text('Contact: ${buyer?.mobile ?? 'N/A'}', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Items Table Header
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
                child: Row(
                  children: [
                    _buildTableCell('Sl No.', flex: 1, isHeader: true),
                    _buildTableCell('Description of Goods', flex: 6, isHeader: true),
                    _buildTableCell('HSN/SAC', flex: 2, isHeader: true),
                    _buildTableCell('Qty', flex: 2, isHeader: true),
                    _buildTableCell('Rate', flex: 2, isHeader: true),
                    _buildTableCell('Amount', flex: 3, isHeader: true),
                  ],
                ),
              ),
              // Items List
              ...List.generate(items.length, (index) {
                final item = items[index];
                return Row(
                  children: [
                    _buildTableCell('${index + 1}', flex: 1),
                    _buildTableCell(item.name ?? '', flex: 6, align: TextAlign.left),
                    _buildTableCell(item.hsnCode ?? '-', flex: 2),
                    _buildTableCell('${item.quantity} ${item.unit}', flex: 2),
                    _buildTableCell(item.rate.toStringAsFixed(2), flex: 2),
                    _buildTableCell(item.amount.toStringAsFixed(2), flex: 3, align: TextAlign.right),
                  ],
                );
              }),
              // Empty space to push totals down (for full preview)
              if (items.isEmpty)
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black)),
                  ),
                ),
              // Tax Rows
              if (controller.hasCGST.value) _buildTaxPreviewRow('CGST', controller.cgstAmount),
              if (controller.hasSGST.value) _buildTaxPreviewRow('SGST', controller.sgstAmount),
              if (controller.hasIGST.value) _buildTaxPreviewRow('IGST', controller.igstAmount),
              // Total Row
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.centerRight,
                        child: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    _buildTableCell('₹${controller.grandTotal.toStringAsFixed(2)}', flex: 3, align: TextAlign.right, isHeader: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Amount Chargeable (in words):', style: StyleResource.instance.styleMedium(fontSize: 10)),
        Text('INR ${controller.grandTotal.toInt().toString()} Only', style: StyleResource.instance.styleBold(fontSize: 11)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bank Details:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                ),
                Text('Bank: ${seller?.bankDetails?.bankName ?? 'N/A'}', style: const TextStyle(fontSize: 9)),
                Text('A/c No: ${seller?.bankDetails?.accountNumber ?? 'N/A'}', style: const TextStyle(fontSize: 9)),
                Text('IFSC: ${seller?.bankDetails?.ifsc ?? 'N/A'}', style: const TextStyle(fontSize: 9)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('for ${seller?.businessName?.toUpperCase() ?? 'YOUR BUSINESS'}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                const Text('Authorised Signatory', style: TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Center(child: Text('This is a Computer Generated Invoice', style: TextStyle(fontSize: 8))),
      ],
    );
  }

  Widget _buildPreviewKeyValue(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(key, style: const TextStyle(fontSize: 8))),
          Text(value, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1, bool isHeader = false, TextAlign align = TextAlign.center}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.black)),
        ),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(fontSize: 9, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildTaxPreviewRow(String label, double amount) {
    return Row(
      children: [
        Expanded(
          flex: 11,
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.centerRight,
            child: Text(label, style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic)),
          ),
        ),
        _buildTableCell(amount.toStringAsFixed(2), flex: 3, align: TextAlign.right),
      ],
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
                _buildModernInfoRow(Icons.pin_rounded, 'GSTIN: ${seller?.gstNumber ?? 'N/A'}'),
                _buildModernInfoRow(Icons.assignment_ind_rounded, 'Tax ID: ${seller?.taxNumber ?? 'N/A'}'),
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
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryLight2, AppColors.white])),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name ?? 'Product Name', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
                                  if (item.hsnCode != null && item.hsnCode!.isNotEmpty) Text('HSN Code: ${item.hsnCode}', style: StyleResource.instance.styleMedium(fontSize: 11, color: AppColors.greyText)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showMagicItemDialog(item: item, index: index),
                              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
                            ),
                            IconButton(
                              onPressed: () => controller.removeItem(index),
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                            ),
                          ],
                        ),
                      ),
                      if (item.description != null && item.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(item.description!, style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText.withOpacity(0.8))),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 15, right: 15, left: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('QTY / RATE', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.greyText).copyWith(letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text('${item.quantity} x ₹${item.rate}', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                              ],
                            ),
                            if (item.discount > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('DISCOUNT', style: StyleResource.instance.styleBold(fontSize: 10, color: Colors.orange).copyWith(letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text('${item.discount}% OFF', style: StyleResource.instance.styleBold(fontSize: 14, color: Colors.orange)),
                                ],
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('TOTAL AMOUNT', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary).copyWith(letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text('₹${item.amount.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
    final settings = controller.appSettings.value?.taxSettings;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TAX CONFIGURATION', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText).copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 10),
          if (settings?.enableCGST ?? true) _buildMagicToggle('CGST (Central)', controller.hasCGST, (v) => controller.toggleCGST(v)),
          if (settings?.enableSGST ?? true) _buildMagicToggle('SGST (State)', controller.hasSGST, (v) => controller.toggleSGST(v)),
          if (settings?.enableIGST ?? true) _buildMagicToggle('IGST (Integrated)', controller.hasIGST, (v) => controller.toggleIGST(v)),
        ],
      ),
    );
  }

  Widget _buildMagicToggle(String label, RxBool state, Function(bool) onChanged) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: InkWell(
          onTap: () => onChanged(!state.value),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: state.value ? AppColors.primary.withOpacity(0.05) : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: state.value ? AppColors.primary.withOpacity(0.3) : AppColors.borderGrey.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: state.value ? AppColors.primary : AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(state.value ? Icons.check_rounded : Icons.add_rounded, size: 16, color: state.value ? AppColors.white : AppColors.greyText),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(label, style: StyleResource.instance.styleBold(fontSize: 14, color: state.value ? AppColors.primary : AppColors.secondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMagicTotalsSection() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.secondary, Color(0xFF1A1F26)]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15))],
        ),
        child: Column(
          children: [
            _buildSummaryLine('Sub Total', '₹${controller.subTotal.toStringAsFixed(2)}'),
            _buildSummaryLine('Discount', '-₹${controller.discountTotal.toStringAsFixed(2)}', valueColor: Colors.redAccent),
            if (controller.hasCGST.value) _buildSummaryLine('CGST (${(controller.hasSGST.value ? controller.taxPercentage.value / 2 : controller.taxPercentage.value).toInt()}%)', '₹${controller.cgstAmount.toStringAsFixed(2)}'),
            if (controller.hasSGST.value) _buildSummaryLine('SGST (${(controller.hasCGST.value ? controller.taxPercentage.value / 2 : controller.taxPercentage.value).toInt()}%)', '₹${controller.sgstAmount.toStringAsFixed(2)}'),
            if (controller.hasIGST.value) _buildSummaryLine('IGST (${controller.taxPercentage.value.toInt()}%)', '₹${controller.igstAmount.toStringAsFixed(2)}'),
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

  void _showMagicItemDialog({InvoiceItem? item, int? index}) {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: item?.name);
    final descCtrl = TextEditingController(text: item?.description);
    final rateCtrl = TextEditingController(text: item?.rate.toString());
    final qtyCtrl = TextEditingController(text: item?.quantity.toString() ?? '1');
    final discountCtrl = TextEditingController(text: item?.discount.toString() ?? '0');
    final hsnCtrl = TextEditingController(text: item?.hsnCode);

    final selectedUnit = (item?.unit ?? controller.selectedInvoiceUnit.value).obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(isEditing ? Icons.edit_document : Icons.add_shopping_cart_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Text(isEditing ? 'EDIT PRODUCT' : 'ADD PRODUCT', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              _buildMagicInput('Product Name', nameCtrl, Icons.shopping_bag_outlined, hint: 'e.g. Website Development'),
              const SizedBox(height: 16),
              _buildMagicInput('Description (Optional)', descCtrl, Icons.notes_rounded, hint: 'Enter product details...', maxLines: 2),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMagicInput('Rate/Price', rateCtrl, Icons.payments_outlined, type: TextInputType.number, hint: '0.00'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMagicInput('Quantity', qtyCtrl, Icons.add_box_outlined, type: TextInputType.number, hint: '1'),
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
                        Text('Unit Type', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText)),
                        const SizedBox(height: 8),
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(color: AppColors.primarySoft.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedUnit.value,
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(16),
                                items: controller.units
                                    .map(
                                      (u) => DropdownMenuItem(
                                        value: u,
                                        child: Text(u, style: StyleResource.instance.styleSemiBold(fontSize: 14)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => selectedUnit.value = v!,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMagicInput('Discount %', discountCtrl, Icons.percent_rounded, type: TextInputType.number, hint: '0'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMagicInput('HSN Code', hsnCtrl, Icons.qr_code_rounded, hint: '9983'),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || rateCtrl.text.isEmpty) {
                      AppSnackbar.showError(title: 'Required', message: 'Enter name and rate');
                      return;
                    }
                    final rate = double.tryParse(rateCtrl.text) ?? 0.0;
                    final qty = double.tryParse(qtyCtrl.text) ?? 1.0;
                    final disc = double.tryParse(discountCtrl.text) ?? 0.0;
                    final amount = (rate * qty) - (rate * qty * (disc / 100));

                    final newItem = InvoiceItem(name: nameCtrl.text, description: descCtrl.text, rate: rate, quantity: qty, discount: disc, hsnCode: hsnCtrl.text, amount: amount, unit: selectedUnit.value);

                    if (isEditing && index != null) {
                      controller.items[index] = newItem;
                      controller.items.refresh();
                    } else {
                      controller.addItem(newItem);
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(isEditing ? 'UPDATE ITEM' : 'ADD TO INVOICE', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMagicInput(String label, TextEditingController ctrl, IconData icon, {TextInputType type = TextInputType.text, String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.greyText).copyWith(letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          maxLines: maxLines,
          style: StyleResource.instance.styleSemiBold(fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: StyleResource.instance.styleMedium(fontSize: 14, color: AppColors.greyText.withOpacity(0.4)),
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
